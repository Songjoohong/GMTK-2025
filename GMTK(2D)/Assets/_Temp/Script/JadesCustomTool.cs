using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;
using UnityObject = UnityEngine.Object;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class JadesCustomTool : EditorWindow
{
    class ParticleSystemAnalysisResult
    {
        public int ShaderComplexityScore;
        public int ParticleCount;
        public float OverdrawEstimate;
        public long ResourceMemoryUsage;
    }

    private List<UnityEngine.Object> selectedAssets = new List<UnityEngine.Object>();
    private List<UnityEngine.Object> usedAssets = new List<UnityEngine.Object>();
    private List<UnityEngine.Object> unusedAssets = new List<UnityEngine.Object>();
    private Vector2 scrollPos;
    private Vector2 scrollPosSelected;
    private Vector2 scrollPosUsed;
    private Vector2 scrollPosUnused;
    private Vector2 scrollPosition;
    private bool showEditParticleSection = true;
    private bool showEtcSection = false;  // Etc 섹션의 foldout 상태
    private bool showOptimizeSection = false;  // Optimize Section의 접힘 상태
    private bool showParticleSystemPresetTool = false;
    private bool showGUIDOverrideTool = false;

    private Dictionary<ParticleSystem, ParticleSystemAnalysisResult> analysisResults = new Dictionary<ParticleSystem, ParticleSystemAnalysisResult>();


    private float hueSlider = 0.0f;
    private float sizeMultiplier = 1.0f;
    private float delayAddition = 0.0f;
    private float sortingFudge;
    private int randomSeedAmount = 0;
    private int seed = 0;

    private bool editCurrentOnly = true;
    private bool editChildren = false;

    private GUIStyle sectionTitleStyle;
    private bool styleInitialized = false;

    private bool isAnalyzeModeActive = false;

    private List<UnityEngine.Object> namingObjects = new List<UnityEngine.Object>();
    private List<string> previewNames = new List<string>();
    private string prefix = "";
    private bool showNamingToolSection = false; // Naming Tool 섹션의 foldout 상태
    private Camera sceneCamera;
    private List<Texture2D> selectedTextures = new List<Texture2D>();
    private string[] availableExtensions = new string[] { "png", "tga" };
    private int selectedExtensionIndex = 0;
    private Vector2 scrollPosTextures;
    private bool overwriteExisting = false;
    private bool showVertexColorOverrideSection = false;
    private Mesh selectedMesh;
    private Texture2D selectedTexture;
    private Vector2 scrollPosVertexColor;

    private float analyzeInterval = 1f; // 1초마다 분석
    private float lastAnalyzeTime = 0f;

    [System.Serializable]
    private class ParticleSystemPreset
{
    public string name;
    public string description; // 새로 추가된 설명 필드
    public string serializedParticleSystem;
    public string serializedRenderer;
    public string additionalRendererInfo;
}

    [System.Serializable]
    private class RendererAdditionalInfo
    {
    public string meshPath;
    public string materialPath;
    public string trailMaterialPath;
    public string[] meshPaths; // 여러 메시를 사용하는 경우를 위해
    }

    private UnityObject sourceAsset;
    private UnityObject targetAsset;

    private List<ParticleSystemPreset> presets = new List<ParticleSystemPreset>();
    private int selectedPresetIndex = -1;
    private string newPresetName = "";
    private Vector2 presetScrollPosition;
    private bool presetsLoaded = false;
    private const string PresetFolderName = "ParticleSystemPresets";
    private static string PresetFolderPath => Path.Combine(Application.dataPath, PresetFolderName);


    private bool showGradientToTextureTool = false;
    private Gradient gradient = new Gradient();
    private int textureSize = 256;
    private bool isVertical = false;




    [MenuItem("Window/Jade FX Tool")]
    public static void ShowWindow()
    {
        JadesCustomTool window = GetWindow<JadesCustomTool>("Jade FX Tool");
        window.InitializeParticlePresets();
    }

    private void InitializeParticlePresets()
    {
        if (!Directory.Exists(PresetFolderPath))
        {
            Directory.CreateDirectory(PresetFolderPath);
        }
        LoadAllPresets();
    }

    private void InitializeStyle()
    {
        if (!styleInitialized)
        {
            sectionTitleStyle = new GUIStyle(EditorStyles.boldLabel)
            {
                fontSize = 20,
                alignment = TextAnchor.MiddleCenter
            };
            styleInitialized = true;
        }
    }

    private void OnGUI()
    {
        InitializeStyle();

        EditorGUILayout.BeginVertical("helpbox");
        EditorGUILayout.Space(10);
        GUILayout.Label("Jade FX Tool v0.20", sectionTitleStyle);
        EditorGUILayout.Space(10);
        EditorGUILayout.EndVertical();

        scrollPos = GUILayout.BeginScrollView(scrollPos);

        showEditParticleSection = EditorGUILayout.Foldout(showEditParticleSection, "Particle System Tool");
        if (showEditParticleSection)
        {
            DrawEditParticleSection();
        }

        showParticleSystemPresetTool = EditorGUILayout.Foldout(showParticleSystemPresetTool, "Particle System Preset");
        if (showParticleSystemPresetTool)
        {
            if (!presetsLoaded)
            {
                LoadPresets();
                presetsLoaded = true;
            }
            DrawParticleSystemPresetTool();
        }

        showEtcSection = EditorGUILayout.Foldout(showEtcSection, "Check AssetUsage Tool");
        if (showEtcSection)
        {
            DrawEtcSection();
        }


        showNamingToolSection = EditorGUILayout.Foldout(showNamingToolSection, "Naming Tool");
        if (showNamingToolSection)
        {
            DrawNamingToolSection();
        }
        
        showVertexColorOverrideSection = EditorGUILayout.Foldout(showVertexColorOverrideSection, "Vertex Color Override Tool");
        if (showVertexColorOverrideSection)
        {
            DrawVertexColorOverrideSection();
        }

        showGradientToTextureTool = EditorGUILayout.Foldout(showGradientToTextureTool, "Gradient Tool");
        if (showGradientToTextureTool)
        {
            DrawGradientToTextureTool();
        }

        showGUIDOverrideTool = EditorGUILayout.Foldout(showGUIDOverrideTool, "GUID Override Tool");
        if (showGUIDOverrideTool)
         {
              DrawGUIDOverrideTool();
          }

        

        GUILayout.EndScrollView();
    }

    private void DrawEditParticleSection()
    {

        EditorGUILayout.BeginVertical("helpbox");
        EditorGUILayout.Space(10);
        editCurrentOnly = EditorGUILayout.Toggle("Current Particle Only", editCurrentOnly);
        if (editCurrentOnly)
        {
            editChildren = false;
        }

        editChildren = EditorGUILayout.Toggle("Current and Its Children", editChildren);
        if (editChildren)
        {
            editCurrentOnly = false;
        }

        EditorGUILayout.Space(10);

        EditorGUILayout.BeginVertical("helpbox");
        
        if (GUILayout.Button("상위 파티클 루트 추가"))
        {
            CreateEmptyRootWithParticleSystem();
        }
        
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(5);
        // Resize


        EditorGUILayout.BeginVertical("helpbox");

        

        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        sizeMultiplier = EditorGUILayout.FloatField("Size Multiplier", sizeMultiplier);
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        if (GUILayout.Button("파티클 스케일 적용"))
        {
            ApplyResize();
        }

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(5);

        EditorGUILayout.BeginVertical("helpbox");
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        delayAddition = EditorGUILayout.FloatField("Delay Amount", delayAddition);
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();
        if (GUILayout.Button("파티클 딜레이 적용" ))
        {
            ApplyDelayAdjustment();
        }
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(5);
        EditorGUILayout.BeginVertical("helpbox");

        // Sorting Fudge 조정 섹션
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        sortingFudge = EditorGUILayout.FloatField("Sorting Fudge Amount", sortingFudge);
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        if (GUILayout.Button("Sorting Fudge Amount 일괄 더하기"))
        {
            ApplySortingFudgeAdjustment();
        }

        if (GUILayout.Button("Sorting Fudge 0으로 초기화"))
        {
            ResetSortingFudge();
        }

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(5);

EditorGUILayout.BeginVertical("helpbox");

// 랜덤시드 난수화 버튼
if (GUILayout.Button("랜덤시드 난수화"))
{
    ApplyRandomSeedRandomization();
}

// 일괄 랜덤시드 적용 버튼
GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
randomSeedAmount = EditorGUILayout.IntField("Random Seed Amount", randomSeedAmount);

 GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();
if (GUILayout.Button("일괄 랜덤시드 적용"))
{
    ApplySameRandomSeedToAll(randomSeedAmount);
}


// Auto Random Seed 활성화 버튼
if (GUILayout.Button("Auto Random Seed 활성화"))
{
    EnableAutoRandomSeed();
}

EditorGUILayout.EndVertical();

EditorGUILayout.Space(5);

        EditorGUILayout.BeginVertical("helpbox");
        if (GUILayout.Button("파티클 정리"))
    {
        if (editCurrentOnly)
        {
            if (Selection.activeGameObject != null)
            {
                var ps = Selection.activeGameObject.GetComponent<ParticleSystem>();
                if (ps != null) ClearParticle(ps);
            }
        }
        else if (editChildren)
        {
            if (Selection.activeGameObject != null)
            {
                var particles = Selection.activeGameObject.GetComponentsInChildren<ParticleSystem>();
                foreach (var ps in particles)
                {
                    ClearParticle(ps);
                }
            }
        }
    }
        
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
    }

    private void ApplyColorAdjustment()
    {
        ApplyEffectBasedOnSelection(EffectType.Color);
    }

    private void ApplyResize()
    {
        ApplyEffectBasedOnSelection(EffectType.Resize);
    }

    private void ApplyDelayAdjustment()
    {
        ApplyEffectBasedOnSelection(EffectType.Delay);
    }
    private void ApplyEffectToParticles(GameObject obj, EffectType effectType)
    {
        ParticleSystem particleSystem = obj.GetComponent<ParticleSystem>();
        if (particleSystem != null)
        {

            Undo.RecordObject(particleSystem, "Particle System Edit");
            var mainModule = particleSystem.main;
            particleSystem.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);

            switch (effectType)
            {
                case EffectType.Color:
                    // 색상 조정 로직...
                    break;
                case EffectType.Resize:
                    ApplyResizeEffects(mainModule, particleSystem);
                    break;
                case EffectType.Delay:
                    ApplyDelayEffect(ref mainModule);
                    break;
                case EffectType.RandomSeedRandomization:
                particleSystem.randomSeed = (uint)UnityEngine.Random.Range(0, 100000);
                break;
                 case EffectType.SameRandomSeed:
                particleSystem.randomSeed = (uint)randomSeedAmount;
                break;
                 case EffectType.AutoRandomSeed:
                particleSystem.useAutoRandomSeed = true;
                break;
            }

            particleSystem.Play(); // 변경 사항 적용을 위해 파티클 시스템 재시작
        }
    }

    private void ApplyResizeEffects(ParticleSystem.MainModule mainModule, ParticleSystem particleSystem)
    {
        if (mainModule.startSize3D)
        {
            mainModule.startSizeX = ResizeParticleParameter(mainModule.startSizeX);
            mainModule.startSizeY = ResizeParticleParameter(mainModule.startSizeY);
            mainModule.startSizeZ = ResizeParticleParameter(mainModule.startSizeZ);
        }
        else
        {
            mainModule.startSize = ResizeParticleParameter(mainModule.startSize);
        }

        mainModule.startSpeed = ResizeParticleParameter(mainModule.startSpeed);
        var shapeModule = particleSystem.shape;
        shapeModule.scale *= sizeMultiplier;
    }

    private ParticleSystem.MinMaxCurve ResizeParticleParameter(ParticleSystem.MinMaxCurve parameter)
    {
        switch (parameter.mode)
        {
            case ParticleSystemCurveMode.Constant:
                return new ParticleSystem.MinMaxCurve(parameter.constant * sizeMultiplier);
            case ParticleSystemCurveMode.TwoConstants:
                return new ParticleSystem.MinMaxCurve(parameter.constantMin * sizeMultiplier, parameter.constantMax * sizeMultiplier);
            default:
                return parameter; // Curve 모드와 Two Curves 모드 처리 필요
        }
    }


    private void ApplyDelayEffect(ref ParticleSystem.MainModule mainModule)
    {
        mainModule.startDelay = AdjustDelayParameter(mainModule.startDelay);
    }

    private ParticleSystem.MinMaxCurve AdjustDelayParameter(ParticleSystem.MinMaxCurve parameter)
    {
        switch (parameter.mode)
        {
            case ParticleSystemCurveMode.Constant:
                return new ParticleSystem.MinMaxCurve(parameter.constant + delayAddition);
            case ParticleSystemCurveMode.TwoConstants:
                return new ParticleSystem.MinMaxCurve(parameter.constantMin + delayAddition, parameter.constantMax + delayAddition);
            default:
                return parameter; // Curve 모드와 Two Curves 모드 처리 필요
        }
    }
    

  private void ClearParticle(ParticleSystem ps)
{
    var main = ps.main;
    var renderer = ps.GetComponent<ParticleSystemRenderer>();
    var emission = ps.emission;

    // Main 모듈 설정 변경
    main.useUnscaledTime = false;
    main.scalingMode = ParticleSystemScalingMode.Hierarchy;
    main.playOnAwake = true;

    // Renderer 모듈 설정 변경
    if (renderer != null)
    {
        renderer.sortingLayerID = SortingLayer.NameToID("Default");
    }

    // Renderer와 Emission 모듈 상태에 따른 추가 처리
    if (renderer != null)
    {
        if (!renderer.enabled && emission.enabled)
        {
            // Renderer가 꺼져 있고 Emission이 켜져 있으면, Emission을 끄고 Renderer 초기화
            emission.enabled = false;
            ResetRenderer(renderer);
        }
        else if (renderer.enabled && !emission.enabled)
        {
            // Renderer가 켜져 있고 Emission이 꺼져 있으면, Renderer를 끄고 초기화
            renderer.enabled = false;
            ResetRenderer(renderer);
        }
    }
    if (!renderer.enabled && !emission.enabled)
    {
        ResetRenderer(renderer);
    }
}

private void ResetRenderer(ParticleSystemRenderer renderer)
{
    renderer.material = null;
    renderer.trailMaterial = null;
    renderer.mesh = null;
    renderer.renderMode = ParticleSystemRenderMode.Billboard;
}

    public void CreateEmptyRootWithParticleSystem()
    {
        List<GameObject> createdParents = new List<GameObject>();
        foreach (var selectedObject in Selection.gameObjects)
        {
            // 새로운 부모 오브젝트 생성
            GameObject newParent = new GameObject("pos");

            // 새로운 부모 오브젝트의 월드 트랜스폼을 선택된 오브젝트의 월드 트랜스폼에 맞춤
            newParent.transform.position = selectedObject.transform.position;
            newParent.transform.rotation = selectedObject.transform.rotation;
            newParent.transform.localScale = selectedObject.transform.lossyScale;

            // 선택된 오브젝트의 현재 부모를 임시로 저장
            Transform originalParent = selectedObject.transform.parent;

            // 선택된 오브젝트를 새로운 부모의 자식으로 설정
            selectedObject.transform.SetParent(newParent.transform, false);

            // 새로운 부모 오브젝트를 원래의 부모 아래로 이동
            newParent.transform.SetParent(originalParent, true);

            // 새로운 부모 오브젝트의 로컬 트랜스폼 초기화
            newParent.transform.localPosition = Vector3.zero;
            newParent.transform.localRotation = Quaternion.identity;
            newParent.transform.localScale = Vector3.one;

            // 새로운 부모에 파티클 시스템 추가 및 설정
            ParticleSystem particleSystem = newParent.AddComponent<ParticleSystem>();
            var main = particleSystem.main;
            main.duration = 5;
            main.loop = false;
            main.scalingMode = ParticleSystemScalingMode.Hierarchy;

            ParticleSystemRenderer renderer = particleSystem.GetComponent<ParticleSystemRenderer>();
            renderer.enabled = false;

            DisableAllParticleSystemModules(particleSystem);
            createdParents.Add(newParent);
        }
        Selection.objects = createdParents.ToArray();
    }
    private void DisableAllParticleSystemModules(ParticleSystem particleSystem)
    {
        var emission = particleSystem.emission;
        emission.enabled = false;

        var shape = particleSystem.shape;
        shape.enabled = false;


    }


    private void ApplyRandomSeedRandomization()
{
    ApplyEffectBasedOnSelection(EffectType.RandomSeedRandomization);
}

private void ApplySameRandomSeedToAll(int seed)
{
    ApplyEffectBasedOnSelection(EffectType.SameRandomSeed, seed);
}

private void EnableAutoRandomSeed()
{
    ApplyEffectBasedOnSelection(EffectType.AutoRandomSeed);
}

    private void ApplyEffectBasedOnSelection(EffectType effectType, int seed = 0)
    {
        if (editCurrentOnly)
        {
            foreach (GameObject obj in Selection.gameObjects)
            {
                ApplyEffectToParticles(obj, effectType);
            }
        }
        else if (editChildren)
        {
            foreach (GameObject obj in Selection.gameObjects)
            {
                ApplyEffectToAllChildren(obj, effectType);
            }
        }
    }
    private void ApplyEffectToAllChildren(GameObject obj, EffectType effectType)
    {
        ApplyEffectToParticles(obj, effectType);

        foreach (Transform child in obj.transform)
        {
            ApplyEffectToAllChildren(child.gameObject, effectType);
        }
    }


    private enum EffectType
    {
        Color,
        Resize,
        Delay,
        RandomSeedRandomization,
        SameRandomSeed,
        AutoRandomSeed
    }



    private void ApplySortingFudgeAdjustment()
{
    foreach (GameObject selectedObject in Selection.gameObjects)
    {
        var ps = selectedObject.GetComponent<ParticleSystem>();
        if (ps != null) AddToSortingFudge(ps, sortingFudge);

        // editChildren 옵션이 활성화되어 있을 경우, 자식 오브젝트들도 처리
        if (editChildren)
        {
            ApplyFudgeToChildren(selectedObject.transform, sortingFudge);
        }
    }
}

private void ApplyFudgeToChildren(Transform parent, float fudgeAmount)
{
    foreach (Transform child in parent)
    {
        var childPs = child.GetComponent<ParticleSystem>();
        if (childPs != null) AddToSortingFudge(childPs, fudgeAmount);

        // 재귀적으로 자식 오브젝트들에 대해서도 동일한 작업 수행
        ApplyFudgeToChildren(child, fudgeAmount);
    }
}


    private void AddToSortingFudge(ParticleSystem ps, float addValue)
    {
        ParticleSystemRenderer renderer = ps.GetComponent<ParticleSystemRenderer>();
        if (renderer != null)
        {
            renderer.sortingFudge += addValue;
        }
    }

    private void SetSortingFudge(ParticleSystem ps, float fudgeValue)
    {
        ParticleSystemRenderer renderer = ps.GetComponent<ParticleSystemRenderer>();
        if (renderer != null)
        {
            renderer.sortingFudge = fudgeValue;
        }
    }

    private void ResetSortingFudge()
    {
        if (Selection.activeGameObject != null)
        {
            var ps = Selection.activeGameObject.GetComponent<ParticleSystem>();
            if (ps != null) SetSortingFudge(ps, 0);

            if (editChildren)
            {
                foreach (Transform child in Selection.activeGameObject.transform)
                {
                    var childPs = child.GetComponent<ParticleSystem>();
                    if (childPs != null) SetSortingFudge(childPs, 0);
                }
            }
        }
    }



    private void DrawEtcSection()
   {
        EditorGUILayout.BeginVertical("helpbox");

        EditorGUILayout.Space(5);

        EditorGUILayout.HelpBox("목록을 등록하여 현재 씬에서 사용되는 에셋인지 검사합니다.", MessageType.Info);

        EditorGUILayout.Space(5);

        if (GUILayout.Button("에셋 선택"))
        {
            SelectAssets();
        }

        if (GUILayout.Button("선택 목록 초기화"))
        {
            selectedAssets.Clear();
            usedAssets.Clear();
            unusedAssets.Clear();
        }

        if (selectedAssets.Count > 0 && GUILayout.Button("현재 씬 사용여부 검색"))
        {
            CheckAssetUsageInScene();
        }

        // 선택된 에셋 목록
        if (selectedAssets.Count > 0)
        {
            EditorGUILayout.LabelField("선택된 에셋 목록:", EditorStyles.boldLabel);
            scrollPosSelected = EditorGUILayout.BeginScrollView(scrollPosSelected, GUILayout.Height(150));
            EditorGUILayout.BeginVertical();
            foreach (var asset in selectedAssets)
            {
                EditorGUILayout.ObjectField(asset, asset.GetType(), false);
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndScrollView();
        }

        // 사용된 에셋 목록
        if (usedAssets.Count > 0)
        {
            EditorGUILayout.LabelField("사용된 에셋 목록:", EditorStyles.boldLabel);
            scrollPosUsed = EditorGUILayout.BeginScrollView(scrollPosUsed, GUILayout.Height(150));
            EditorGUILayout.BeginVertical();
            foreach (var asset in usedAssets)
            {
                EditorGUILayout.ObjectField(asset, asset.GetType(), false);
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndScrollView();

            if (GUILayout.Button("사용된 에셋 선택"))
            {
                SelectAssetsInProject(usedAssets);
            }
        }

        // 사용되지 않는 에셋 목록
        if (unusedAssets.Count > 0)
        {
            EditorGUILayout.LabelField("사용되지 않는 에셋 목록:", EditorStyles.boldLabel);
            scrollPosUnused = EditorGUILayout.BeginScrollView(scrollPosUnused, GUILayout.Height(150));
            EditorGUILayout.BeginVertical();
            foreach (var asset in unusedAssets)
            {
                EditorGUILayout.ObjectField(asset, asset.GetType(), false);
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndScrollView();

            if (GUILayout.Button("사용되지 않는 에셋 선택"))
            {
                SelectAssetsInProject(unusedAssets);
            }
        }

        EditorGUILayout.Space(10);
        EditorGUILayout.EndVertical();
    }


    private void SelectAssets()
    {
        selectedAssets.Clear();
        usedAssets.Clear();
        unusedAssets.Clear();

        string[] guids = Selection.assetGUIDs;
        foreach (string guid in guids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);

            if (asset != null && (asset is Material || asset is Mesh || asset is Texture))
            {
                selectedAssets.Add(asset);
            }
        }

        Repaint();
    }

    private void CheckAssetUsageInScene()
{
    usedAssets.Clear();
    unusedAssets.Clear();

    ParticleSystem[] particleSystems = FindObjectsOfType<ParticleSystem>();
    MeshRenderer[] meshRenderers = FindObjectsOfType<MeshRenderer>();

    foreach (var asset in selectedAssets)
    {
        bool isUsed = false;

        // 파티클 시스템 검사
        foreach (var ps in particleSystems)
        {
            if (IsAssetUsedInParticleSystem(ps, asset))
            {
                usedAssets.Add(asset);
                isUsed = true;
                break;
            }
        }

        // MeshRenderer 검사
        if (!isUsed)
        {
            foreach (var renderer in meshRenderers)
            {
                if (IsAssetUsedInRenderer(renderer, asset))
                {
                    usedAssets.Add(asset);
                    isUsed = true;
                    break;
                }
            }
        }

        if (!isUsed)
        {
            unusedAssets.Add(asset);
        }
    }
}

    private bool IsAssetUsedInRenderer(Renderer renderer, UnityEngine.Object asset)
    {
    if (asset is Material material)
    {
        return renderer.sharedMaterials.Contains(material);
    }
    else if (asset is Mesh mesh && renderer is MeshRenderer meshRenderer)
    {
        MeshFilter meshFilter = meshRenderer.GetComponent<MeshFilter>();
        return meshFilter != null && meshFilter.sharedMesh == mesh;
    }
    else if (asset is Texture texture)
    {
        foreach (Material mat in renderer.sharedMaterials)
        {
            if (mat != null)
            {
                string[] texturePropertyNames = mat.GetTexturePropertyNames();
                foreach (string propertyName in texturePropertyNames)
                {
                    if (mat.GetTexture(propertyName) == texture)
                    {
                        return true;
                    }
                }
            }
        }
    }

    return false;
    }

    private bool IsAssetUsedInParticleSystem(ParticleSystem ps, UnityEngine.Object asset)
    {
    var renderer = ps.GetComponent<ParticleSystemRenderer>();
    return IsAssetUsedInRenderer(renderer, asset);
    }

    private void SelectAssetsInProject(List<UnityEngine.Object> assets)
    {
        Selection.objects = assets.ToArray();
    }

    private void SelectMaterialsInProject(List<Material> materials)
    {
        UnityEngine.Object[] objects = new UnityEngine.Object[materials.Count];
        for (int i = 0; i < materials.Count; i++)
        {
            objects[i] = materials[i];
        }
        Selection.objects = objects;
    }

    // Naming Tool 섹션을 그리는 메서드
private void DrawNamingToolSection()
{
    EditorGUILayout.BeginVertical("helpbox");
    EditorGUILayout.Space(5);

    EditorGUILayout.HelpBox("목록을 등록하여 네이밍을 일괄 수정할 수 있습니다.", MessageType.Info);

    EditorGUILayout.Space(5);

    if (GUILayout.Button("선택 목록 등록"))
    {
        RegisterNamingSelection();
    }

    if (GUILayout.Button("선택 목록 초기화"))
    {
        namingObjects.Clear();
        previewNames.Clear();
    }

    
    if (namingObjects.Count > 0)
    {
        EditorGUILayout.BeginVertical("helpbox");
        EditorGUILayout.Space(10);
        GUILayout.Label("Preview of Changes:");
        for (int i = 0; i < namingObjects.Count; i++)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.ObjectField(namingObjects[i], typeof(UnityEngine.Object), false);
            GUILayout.Label(" => " + previewNames[i]);
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(5);
    }
    


   
    if (namingObjects.Count > 0)
    {
        EditorGUILayout.BeginVertical("helpbox");
        if (GUILayout.Button("네이밍 초기화"))
        {
        ClearNames();
        }
        EditorGUILayout.EndVertical();
        
        EditorGUILayout.Space(5);
    }
    

    
    if (namingObjects.Count > 0)
    {
        EditorGUILayout.BeginVertical("helpbox");
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        prefix = EditorGUILayout.TextField("접두어", prefix, GUILayout.Width(400f));
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        if (GUILayout.Button("일괄 접두어 적용"))
         {
             ApplyPrefix();
          }
         GUILayout.EndVertical();
         EditorGUILayout.Space(5);
    }

    
    
    if (namingObjects.Count > 0)
    {
        EditorGUILayout.BeginVertical("helpbox");
        if (GUILayout.Button("번호 붙이기 적용"))
        {
            AddSequentialNumbers();
        }
        EditorGUILayout.EndVertical();
    }

    EditorGUILayout.Space(10);
    
    
    if (namingObjects.Count > 0)
    {
        EditorGUILayout.BeginVertical("helpbox");
        if(GUILayout.Button("네이밍 적용"))
        {
            ApplyNamingChanges();
        }
        EditorGUILayout.EndVertical();
    }

    EditorGUILayout.EndVertical();
    EditorGUILayout.Space(5);

}

// 선택한 파일들을 등록하는 메서드
private void RegisterNamingSelection()
{
    namingObjects = new List<UnityEngine.Object>(Selection.objects);
    previewNames = namingObjects.Select(obj => obj.name).ToList();
}

// 선택한 파일들의 이름을 빈칸으로 만드는 메서드
private void ClearNames()
{
    previewNames = namingObjects.Select(obj => string.Empty).ToList();
}

// 접두어를 적용하는 메서드
private void ApplyPrefix()
{
    for (int i = 0; i < namingObjects.Count; i++)
    {
        previewNames[i] = prefix + previewNames[i];
    }
}

// 순차적 번호를 추가하는 메서드
private void AddSequentialNumbers()
{
    int numberLength = 2; // 항상 2자리 숫자를 사용합니다.
    for (int i = 0; i < namingObjects.Count; i++)
    {
        string number = (i + 1).ToString().PadLeft(numberLength, '0');
        previewNames[i] = previewNames[i] + "_" + number;
    }
}

// 네이밍 변경을 적용하는 메서드
private void ApplyNamingChanges()
{
    for (int i = 0; i < namingObjects.Count; i++)
    {
        if (namingObjects[i] is GameObject) // 계층 구조 뷰의 게임 오브젝트인 경우
        {
            Undo.RecordObject(namingObjects[i], "Rename GameObject");
            namingObjects[i].name = previewNames[i];
        }
        else // 프로젝트 뷰의 에셋인 경우
        {
            string assetPath = AssetDatabase.GetAssetPath(namingObjects[i]);
            AssetDatabase.RenameAsset(assetPath, previewNames[i]);
        }
    }
    AssetDatabase.SaveAssets(); // 에셋 변경 사항 저장
    EditorSceneManager.MarkAllScenesDirty(); // 씬 변경 사항 표시
}

bool SetTextureReadable(Texture2D texture, bool isReadable)
{
    if (texture == null) return false;

    string assetPath = AssetDatabase.GetAssetPath(texture);
    var textureImporter = AssetImporter.GetAtPath(assetPath) as TextureImporter;

    if (textureImporter == null) return false;

    bool wasReadable = textureImporter.isReadable;
    if (textureImporter.isReadable != isReadable)
    {
        textureImporter.isReadable = isReadable;
        AssetDatabase.ImportAsset(assetPath);
        AssetDatabase.Refresh();
    }

    return wasReadable;
}


private void DrawVertexColorOverrideSection()
    {
        EditorGUILayout.BeginVertical("helpbox");
        EditorGUILayout.Space(5);

        EditorGUILayout.HelpBox("메쉬의 UV를 기준으로 버텍스 컬러에 텍스쳐를 입력합니다.", MessageType.Info);
        EditorGUILayout.Space(5);
        GUILayout.Label("메쉬 선택:", EditorStyles.boldLabel);
        selectedMesh = (Mesh)EditorGUILayout.ObjectField(selectedMesh, typeof(Mesh), false);

        EditorGUILayout.Space(10);
        GUILayout.Label("텍스처 선택:", EditorStyles.boldLabel);
        selectedTexture = (Texture2D)EditorGUILayout.ObjectField(selectedTexture, typeof(Texture2D), false);

        EditorGUILayout.Space(10);

        if (GUILayout.Button("버텍스 컬러 오버라이드") && selectedMesh != null && selectedTexture != null)
        {
            OverrideVertexColors(selectedMesh, selectedTexture);
        }

        EditorGUILayout.Space(5);

        if (GUILayout.Button("버텍스 알파 오버라이드(기준은 R채널)") && selectedMesh != null && selectedTexture != null)
        {
            OverrideVertexAlpha(selectedMesh, selectedTexture);
        }

        EditorGUILayout.Space(5);

        if (GUILayout.Button("버텍스 컬러 및 알파 초기화") && selectedMesh != null)
        {
            ResetVertexColors(selectedMesh);
        }

        EditorGUILayout.Space(5);

        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
    }

    void OverrideVertexColors(Mesh mesh, Texture2D texture)
    {

        
        Vector2[] uv = mesh.uv;
        Color[] colors = new Color[uv.Length];

        bool wasReadable = SetTextureReadable(texture, true);

        for (int i = 0; i < uv.Length; i++)
        {
            colors[i] = texture.GetPixelBilinear(uv[i].x, uv[i].y);
        }

        mesh.colors = colors;

        if (!Application.isPlaying)
        {
            Undo.RecordObject(mesh, "Vertex Color Override");
            EditorUtility.SetDirty(mesh);
            AssetDatabase.SaveAssets();
        }

        SetTextureReadable(texture, wasReadable); // 원래 설정으로 되돌림
    }

    void OverrideVertexAlpha(Mesh mesh, Texture2D texture)
{
    bool wasReadable = SetTextureReadable(texture, true);

    Vector2[] uv = mesh.uv;
    Color[] colors = mesh.colors;

    // colors 배열이 정의되어 있지 않거나 길이가 uv 배열과 다르면 새로 생성
    if (colors == null || colors.Length != uv.Length)
    {
        colors = new Color[uv.Length];
        for (int i = 0; i < uv.Length; i++)
        {
            colors[i] = Color.white; // 기본값을 흰색으로 설정
        }
    }

    for (int i = 0; i < uv.Length; i++)
    {
        Color textureColor = texture.GetPixelBilinear(uv[i].x, uv[i].y);
        // 기존의 RGB 값을 유지하면서 알파값만 수정
        colors[i] = new Color(colors[i].r, colors[i].g, colors[i].b, textureColor.r);
    }

    mesh.colors = colors;

    SetTextureReadable(texture, wasReadable); // 원래 설정으로 되돌림
}
    void ResetVertexColors(Mesh mesh)
{
    Color[] colors = new Color[mesh.vertexCount];

    for (int i = 0; i < colors.Length; i++)
    {
        colors[i] = Color.white; // RGB = 1, 알파 = 1
    }

    mesh.colors = colors;
}

      private void DrawParticleSystemPresetTool()
{
    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
    EditorGUILayout.Space(10);

    ParticleSystem selectedParticleSystem = Selection.activeGameObject?.GetComponent<ParticleSystem>();

    // 선택된 파티클 시스템 정보 표시
    if (selectedParticleSystem != null)
    {
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("현재 선택된 파티클 :", EditorStyles.boldLabel, GUILayout.Width(180));
        EditorGUILayout.LabelField(selectedParticleSystem.name);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        // 새 프리셋 저장 UI
        EditorGUILayout.BeginHorizontal();
        newPresetName = EditorGUILayout.TextField("새 프리셋 이름", newPresetName);
        if (GUILayout.Button("새 프리셋으로 저장하기", GUILayout.Width(150)))
        {
            SavePreset(selectedParticleSystem, newPresetName);
            newPresetName = "";
        }
        EditorGUILayout.EndHorizontal();
    }
    else
    {
        EditorGUILayout.HelpBox("새 프리셋을 만들거나 적용하려면 파티클 시스템을 선택해주세요.", MessageType.Info);
    }

    EditorGUILayout.Space();

    // 프리셋 목록 표시 (항상 표시)
    EditorGUILayout.LabelField("저장된 프리셋 목록", EditorStyles.boldLabel);
    if (presets.Count > 0)
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        presetScrollPosition = EditorGUILayout.BeginScrollView(presetScrollPosition, GUILayout.Height(200));
        
        for (int i = 0; i < presets.Count; i++)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(presets[i].name, EditorStyles.boldLabel);
            
            GUI.enabled = selectedParticleSystem != null;
            if (GUILayout.Button("적용", GUILayout.Width(60)))
            {
                ApplyPreset(selectedParticleSystem, presets[i]);
            }
            GUI.enabled = true;

            if (GUILayout.Button("수정", GUILayout.Width(60)))
            {
                EditPreset(i);
            }
            if (GUILayout.Button("삭제", GUILayout.Width(60)))
            {
                DeletePreset(i);
                break;
            }
            EditorGUILayout.EndHorizontal();

            if (!string.IsNullOrEmpty(presets[i].description))
            {
                EditorGUILayout.LabelField(presets[i].description, EditorStyles.wordWrappedLabel);
            }

            EditorGUILayout.EndVertical();
            EditorGUILayout.Space();
        }

        EditorGUILayout.EndScrollView();
        EditorGUILayout.EndVertical();
    }
    else
    {
        EditorGUILayout.HelpBox("아직 저장된 프리셋이 없습니다.", MessageType.Info);
    }
    EditorGUILayout.Space(10);

    EditorGUILayout.EndVertical();
}


private void LoadAllPresets()
    {
        presets.Clear();
        string[] presetFiles = Directory.GetFiles(PresetFolderPath, "*.json");
        foreach (string filePath in presetFiles)
        {
            try
            {
                string json = File.ReadAllText(filePath);
                ParticleSystemPreset preset = JsonUtility.FromJson<ParticleSystemPreset>(json);
                if (preset != null)
                {
                    presets.Add(preset);
                }
            }
            catch (Exception e)
            {
                Debug.LogError($"Error loading preset from {filePath}: {e.Message}");
            }
        }
    }


  private void SavePreset(ParticleSystem particleSystem, string presetName)
{

    if (!Directory.Exists(PresetFolderPath))
    {
        Directory.CreateDirectory(PresetFolderPath);
    }

    if (string.IsNullOrEmpty(presetName))
    {
        EditorUtility.DisplayDialog("Invalid Name", "정상적인 이름을 입력해주세요.", "OK");
        return;
    }

    // 설명 입력 받기
    string description = EditorInputDialog.Show("Preset Description", "해당 프리셋의 설명을 입력해주세요(선택) :", "");

    ParticleSystemRenderer renderer = particleSystem.GetComponent<ParticleSystemRenderer>();

    // 파티클 시스템 직렬화
    string serializedParticleSystem = EditorJsonUtility.ToJson(particleSystem);

    // 렌더러 직렬화
    string serializedRenderer = EditorJsonUtility.ToJson(renderer);

    // 추가 렌더러 정보 저장
    RendererAdditionalInfo additionalInfo = new RendererAdditionalInfo
    {
        meshPath = renderer.mesh != null ? AssetDatabase.GetAssetPath(renderer.mesh) : "",
        materialPath = renderer.sharedMaterial != null ? AssetDatabase.GetAssetPath(renderer.sharedMaterial) : "",
        trailMaterialPath = renderer.trailMaterial != null ? AssetDatabase.GetAssetPath(renderer.trailMaterial) : "",
        meshPaths = new string[renderer.meshCount]
    };

    // 여러 메시 경로 저장 (렌더 모드가 Mesh일 경우)
    if (renderer.renderMode == ParticleSystemRenderMode.Mesh)
    {
        for (int i = 0; i < renderer.meshCount; i++)
        {
            Mesh mesh = renderer.mesh; // 현재는 모든 슬롯에 동일한 메시가 사용됨
            additionalInfo.meshPaths[i] = mesh != null ? AssetDatabase.GetAssetPath(mesh) : "";
        }
    }

    ParticleSystemPreset newPreset = new ParticleSystemPreset
    {
        name = presetName,
        description = description,
        serializedParticleSystem = serializedParticleSystem,
        serializedRenderer = serializedRenderer,
        additionalRendererInfo = JsonUtility.ToJson(additionalInfo)
    };

    string filePath = Path.Combine(PresetFolderPath, $"{presetName}.json");


    try
    {
        string directoryPath = Path.GetDirectoryName(filePath);
        if (!Directory.Exists(directoryPath))
        {
            Directory.CreateDirectory(directoryPath);
        }

        string json = JsonUtility.ToJson(newPreset, true);
        File.WriteAllText(filePath, json);

        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("Preset Saved", "프리셋이 저장되었습니다.", "OK");
    }
    catch (Exception e)
    {
        Debug.LogError($"Error saving preset: {e.Message}");
        EditorUtility.DisplayDialog("Error", $"Failed to save preset: {e.Message}", "OK");
    }

    LoadAllPresets();
    AssetDatabase.Refresh();

    EditorUtility.DisplayDialog("Preset Saved", "프리셋이 저장되었습니다.", "OK");
}

    private void ApplyPreset(ParticleSystem particleSystem, ParticleSystemPreset preset)
{
    Undo.RecordObject(particleSystem, "Apply Particle System Preset");
    EditorJsonUtility.FromJsonOverwrite(preset.serializedParticleSystem, particleSystem);

    ParticleSystemRenderer renderer = particleSystem.GetComponent<ParticleSystemRenderer>();
    Undo.RecordObject(renderer, "Apply Particle System Renderer Preset");
    EditorJsonUtility.FromJsonOverwrite(preset.serializedRenderer, renderer);

    // 메시와 머테리얼 참조 복원
    RestoreRendererReferences(renderer);

    EditorUtility.SetDirty(particleSystem);
    EditorUtility.SetDirty(renderer);
    EditorUtility.DisplayDialog("Preset Applied", "프리셋이 선택한 파티클에 반영되었습니다.", "OK");
}

    private void SavePresets()
    {
    string json = JsonUtility.ToJson(new { presets = presets });
    string filePath = Path.Combine(Application.dataPath, "ParticleSystemPresets.json");
    File.WriteAllText(filePath, json);
    AssetDatabase.Refresh();
    }

    private void LoadPresets()
    {
        string filePath = GetPresetFilePath();
        if (File.Exists(filePath))
        {
            string json = File.ReadAllText(filePath);
            JsonUtility.FromJsonOverwrite(json, new { presets = presets });
        }
    }

    private string GetPresetFilePath()
    {
        return Path.Combine(Application.dataPath, "ParticleSystemPresets.json");
    }

    private void InitializeParticleSystemPresets()
    {
        LoadPresets();
    }

    private void RestoreRendererReferences(ParticleSystemRenderer renderer)
{
    // 메시 복원
    if (renderer.mesh != null && !string.IsNullOrEmpty(AssetDatabase.GetAssetPath(renderer.mesh)))
    {
        renderer.mesh = AssetDatabase.LoadAssetAtPath<Mesh>(AssetDatabase.GetAssetPath(renderer.mesh));
    }

    // 머테리얼 복원
    if (renderer.sharedMaterial != null && !string.IsNullOrEmpty(AssetDatabase.GetAssetPath(renderer.sharedMaterial)))
    {
        renderer.sharedMaterial = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GetAssetPath(renderer.sharedMaterial));
    }

    // 트레일 머테리얼 복원
    if (renderer.trailMaterial != null && !string.IsNullOrEmpty(AssetDatabase.GetAssetPath(renderer.trailMaterial)))
    {
        renderer.trailMaterial = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GetAssetPath(renderer.trailMaterial));
    }

    // 렌더 모드에 따른 추가 참조 복원
    if (renderer.renderMode == ParticleSystemRenderMode.Mesh)
    {
        Mesh[] meshes = new Mesh[renderer.meshCount];
        for (int i = 0; i < renderer.meshCount; i++)
        {
            meshes[i] = renderer.mesh; // 모든 메시 슬롯에 동일한 메시 할당
        }
        renderer.SetMeshes(meshes, renderer.meshCount);
    }
}

    private void DeletePreset(int index)
    {
        if (index < 0 || index >= presets.Count) return;

        string presetName = presets[index].name;
        string filePath = Path.Combine(PresetFolderPath, $"{presetName}.json");

        if (File.Exists(filePath))
        {
            File.Delete(filePath);
            AssetDatabase.Refresh();
        }

        LoadAllPresets(); // 삭제 후 모든 프리셋을 다시 로드
    }



    private void EditPreset(int index)
{
    if (index < 0 || index >= presets.Count)
    {
        Debug.LogError("유효하지 않은 프리셋 인덱스입니다.");
        return;
    }

    string oldName = presets[index].name;
    string oldFilePath = Path.Combine(PresetFolderPath, $"{oldName}.json");

    PresetEditWindow.ShowWindow(presets[index], () => 
    {
        string newName = presets[index].name;
        string newFilePath = Path.Combine(PresetFolderPath, $"{newName}.json");

        // 이름이 변경되었다면 파일 이름도 변경
        if (oldName != newName)
        {
            if (File.Exists(oldFilePath))
            {
                File.Move(oldFilePath, newFilePath);
            }
            else
            {
                Debug.LogWarning($"원본 파일을 찾을 수 없습니다: {oldFilePath}");
            }
        }

        // 프리셋 내용 업데이트
        string json = JsonUtility.ToJson(presets[index], true);
        File.WriteAllText(newFilePath, json);

        AssetDatabase.Refresh();
        LoadAllPresets(); // 모든 프리셋을 다시 로드

        EditorUtility.DisplayDialog("프리셋 업데이트", "프리셋이 성공적으로 업데이트되었습니다.", "확인");
    });
}

private class PresetEditWindow : EditorWindow
{
    private ParticleSystemPreset preset;
    private System.Action onSave;

    public static void ShowWindow(ParticleSystemPreset preset, System.Action onSave)
    {
        PresetEditWindow window = GetWindow<PresetEditWindow>("Edit Preset");
        window.preset = preset;
        window.onSave = onSave;
        window.Show();
    }

    private void OnGUI()
{
    EditorGUILayout.LabelField("프리셋 편집", EditorStyles.boldLabel);
    EditorGUILayout.Space();

    string newName = EditorGUILayout.TextField("프리셋 이름", preset.name);
    if (newName != preset.name && File.Exists(Path.Combine(PresetFolderPath, $"{newName}.json")))
    {
        EditorGUILayout.HelpBox("이 이름의 프리셋이 이미 존재합니다.", MessageType.Warning);
    }
    else
    {
        preset.name = newName;
    }
    
    EditorGUILayout.LabelField("설명:");
    preset.description = EditorGUILayout.TextArea(preset.description, GUILayout.Height(100));

    EditorGUILayout.Space();

    if (GUILayout.Button("변경 사항 저장"))
    {
        onSave?.Invoke();
        Close();
    }
}
}

private void DrawGradientToTextureTool()
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space(5);

        EditorGUILayout.HelpBox("그라디언트를 TGA 파일로 저장합니다.", MessageType.Info);

        EditorGUILayout.Space(5);

        gradient = EditorGUILayout.GradientField("그라디언트", gradient);
        textureSize = EditorGUILayout.IntField("텍스처 크기", textureSize);
        isVertical = EditorGUILayout.Toggle("세로 방향", isVertical);

        if (GUILayout.Button("저장하기"))
        {
            CreateGradientTexture();
        }
        EditorGUILayout.Space(5);
        EditorGUILayout.EndVertical();
    }




    private void CreateGradientTexture()
    {
        int width = isVertical ? 1 : textureSize;
        int height = isVertical ? textureSize : 1;

        Texture2D gradientTexture = new Texture2D(width, height, TextureFormat.RGBA32, false);

        for (int i = 0; i < textureSize; i++)
        {
            Color color = gradient.Evaluate((float)i / (textureSize - 1));
            if (isVertical)
            {
                gradientTexture.SetPixel(0, i, color);
            }
            else
            {
                gradientTexture.SetPixel(i, 0, color);
            }
        }

        gradientTexture.Apply();

        // 텍스처를 Targa 파일로 저장
        byte[] bytes = gradientTexture.EncodeToTGA();
        string defaultName = isVertical ? "VerticalGradient" : "HorizontalGradient";
        string path = EditorUtility.SaveFilePanel("Save Gradient Texture", "Assets", defaultName, "tga");
        if (!string.IsNullOrEmpty(path))
        {
            File.WriteAllBytes(path, bytes);
            AssetDatabase.Refresh();

            // 텍스처 임포트 설정 변경
            string relativePath = "Assets" + path.Substring(Application.dataPath.Length);
            TextureImporter importer = AssetImporter.GetAtPath(relativePath) as TextureImporter;
            if (importer != null)
            {
                importer.textureType = TextureImporterType.Default;
                importer.alphaIsTransparency = true;
                importer.filterMode = FilterMode.Bilinear;
                importer.wrapMode = TextureWrapMode.Clamp;
                importer.SaveAndReimport();
            }

            Debug.Log("그라디언트 맵이 저장되었습니다.: " + path);
        }
    }



private void DrawGUIDOverrideTool()
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space(10);


        sourceAsset = EditorGUILayout.ObjectField("원본 에셋 (A)", sourceAsset, typeof(UnityObject), false);
        targetAsset = EditorGUILayout.ObjectField("대상 에셋 (B)", targetAsset, typeof(UnityObject), false);

        EditorGUILayout.Space(10);

        EditorGUILayout.HelpBox("B 에셋의 GUID가 A 에셋의 GUID로 변경되고, A 에셋은 삭제됩니다.", MessageType.Warning);

        if (GUILayout.Button("GUID 덮어쓰기 및 원본 삭제"))
        {
            if (EditorUtility.DisplayDialog("경고", "이 작업은 되돌릴 수 없습니다. 계속하시겠습니까?", "예", "아니오"))
            {
                OverrideGUIDAndDeleteSource();
            }
        }
        EditorGUILayout.Space(5);
        EditorGUILayout.EndVertical();
    }

private void OverrideGUIDAndDeleteSource()
    {
        if (sourceAsset == null || targetAsset == null)
        {
            Debug.LogError("원본 에셋과 대상 에셋을 모두 선택해야 합니다.");
            return;
        }

        string sourcePath = AssetDatabase.GetAssetPath(sourceAsset);
        string targetPath = AssetDatabase.GetAssetPath(targetAsset);

        string sourceGUID = AssetDatabase.AssetPathToGUID(sourcePath);
        string targetGUID = AssetDatabase.AssetPathToGUID(targetPath);

        if (string.IsNullOrEmpty(sourceGUID) || string.IsNullOrEmpty(targetGUID))
        {
            Debug.LogError("유효하지 않은 에셋입니다.");
            return;
        }

        string targetMetaPath = targetPath + ".meta";
        if (!File.Exists(targetMetaPath))
        {
            Debug.LogError("대상 에셋의 메타 파일을 찾을 수 없습니다.");
            return;
        }

        // 대상 에셋의 메타 파일에서 GUID 변경
        string metaContent = File.ReadAllText(targetMetaPath);
        metaContent = metaContent.Replace(targetGUID, sourceGUID);
        File.WriteAllText(targetMetaPath, metaContent);

        // 원본 에셋 삭제
        AssetDatabase.DeleteAsset(sourcePath);

        AssetDatabase.Refresh();
        Debug.Log("GUID 덮어쓰기 완료 및 원본 에셋 삭제됨. 프로젝트의 참조를 확인하세요.");

        // 작업 후 필드 초기화
        sourceAsset = null;
        targetAsset = null;
    }




    public class EditorInputDialog : EditorWindow
{
    public static string Show(string title, string message, string defaultText = "")
    {
        EditorInputDialog window = CreateInstance<EditorInputDialog>();
        window.titleContent = new GUIContent(title);
        window.message = message;
        window.inputText = defaultText;
        window.ShowModal();
        return window.inputText;
    }

    private string message = "";
    private string inputText = "";

    private void OnGUI()
    {
        EditorGUILayout.LabelField(message);
        inputText = EditorGUILayout.TextField(inputText);

        if (GUILayout.Button("OK") || Event.current.keyCode == KeyCode.Return)
        {
            Close();
        }
    }
}

}
