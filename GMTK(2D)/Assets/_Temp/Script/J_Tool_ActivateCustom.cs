using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

#if UNITY_EDITOR
public static class J_Tool_ActivateCustom
{
    [MenuItem("CONTEXT/ParticleSystem/Custom Data 활성화")]
    private static void ActivateCustomData(MenuCommand command)
    {
        ParticleSystem ps = (ParticleSystem)command.context;
        ParticleSystemRenderer psRenderer = ps.GetComponent<ParticleSystemRenderer>();

        Undo.RecordObject(ps, "Activate Custom Data for ParticleSystem");
        Undo.RecordObject(psRenderer, "Activate Custom Vertex Streams for ParticleSystemRenderer");


        var streams = new List<ParticleSystemVertexStream>
        {
            ParticleSystemVertexStream.Position,
            ParticleSystemVertexStream.Normal,
            ParticleSystemVertexStream.Color,
            ParticleSystemVertexStream.UV,
            ParticleSystemVertexStream.UV2,
            ParticleSystemVertexStream.Custom1XYZW,
            ParticleSystemVertexStream.Custom2XYZW
        };

        psRenderer.SetActiveVertexStreams(streams);

        var customDataModule = ps.customData;
        customDataModule.enabled = true; 
        customDataModule.SetMode(ParticleSystemCustomData.Custom1, ParticleSystemCustomDataMode.Vector);
        customDataModule.SetVectorComponentCount(ParticleSystemCustomData.Custom1, 4);
        customDataModule.SetMode(ParticleSystemCustomData.Custom2, ParticleSystemCustomDataMode.Vector);
        customDataModule.SetVectorComponentCount(ParticleSystemCustomData.Custom2, 4);

        EditorUtility.SetDirty(ps);
        EditorUtility.SetDirty(psRenderer);
    }
}
#endif