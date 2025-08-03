using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager Instance;

    private Dictionary<string, AudioClip> clipDict = new Dictionary<string, AudioClip>();

    [Header("Assigned AudioSources")]
    public AudioSource uiAudioSource;
    public AudioSource bgmAudioSource;
    public AudioSource effectAudioSource;

    [Header("AudioSource Pooling for overlapping sounds")]
    public AudioSource audioSourcePrefab; // �� AudioSource ������
    public int poolSize = 10;
    private List<AudioSource> audioSourcePool = new List<AudioSource>();

    // �ĺ��� �̸� (Resources/Sounds ���� ���� ���� ���� �̸��� �°�)
    private string[] walkStepSoundNames = { "SFX_Walk_1", "SFX_Walk_2", "SFX_Walk_3" };
    private string[] jumpSoundNames = { "SFX_Chick_Jump 1", "SFX_Chick_Jump 2", "SFX_Chick_Jump 3", "SFX_Chick_Jump 4" };

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;

        // Resources/Sounds �������� ��� AudioClip �ε�
        AudioClip[] clips = Resources.LoadAll<AudioClip>("Sounds");
        clipDict.Clear();
        foreach (var clip in clips)
        {
            if (!clipDict.ContainsKey(clip.name))
                clipDict.Add(clip.name, clip);
        }

        // AudioSource Ǯ �ʱ�ȭ
        for (int i = 0; i < poolSize; i++)
        {
            AudioSource src = Instantiate(audioSourcePrefab, transform);
            src.playOnAwake = false;
            audioSourcePool.Add(src);
        }
    }

    private AudioSource GetAvailableAudioSource()
    {
        foreach (var src in audioSourcePool)
        {
            if (!src.isPlaying)
                return src;
        }
        AudioSource newSrc = Instantiate(audioSourcePrefab, transform);
        newSrc.playOnAwake = false;
        audioSourcePool.Add(newSrc);
        return newSrc;
    }

    // �ĺ��� �迭���� ���� ���� ���
    private void PlayRandomOneShot(string[] candidateNames)
    {
        if (candidateNames == null || candidateNames.Length == 0) return;

        string chosen = candidateNames[Random.Range(0, candidateNames.Length)];
        PlayOneShotSound(chosen);
    }

    public void PlayUISound(string clipName)
    {
        if (clipDict.TryGetValue(clipName, out var clip))
        {
            if (uiAudioSource.isPlaying)
                uiAudioSource.Stop();
            uiAudioSource.clip = clip;
            uiAudioSource.Play();
        }
        else
        {
            Debug.LogWarning($"UI Sound not found: {clipName}");
        }
    }

    public void PlayBGM(string clipName, bool loop = true)
    {
        if (clipDict.TryGetValue(clipName, out var clip))
        {
            bgmAudioSource.clip = clip;
            bgmAudioSource.loop = loop;
            bgmAudioSource.Play();
        }
        else
        {
            Debug.LogWarning($"BGM not found: {clipName}");
        }
    }

    public void PlayEffectSound(string clipName)
    {
        if (clipDict.TryGetValue(clipName, out var clip))
        {
            if (effectAudioSource.isPlaying)
                effectAudioSource.Stop();
            effectAudioSource.clip = clip;
            effectAudioSource.Play();
        }
        else
        {
            Debug.LogWarning($"Effect sound not found: {clipName}");
        }
    }

    public void PlayOneShotSound(string clipName)
    {
        if (clipDict.TryGetValue(clipName, out var clip))
        {
            AudioSource src = GetAvailableAudioSource();
            src.PlayOneShot(clip);
        }
        else
        {
            Debug.LogWarning($"OneShot sound not found: {clipName}");
        }
    }

    // �ȱ� �߰��� �Ҹ� ���� ���
    public void PlayRandomWalkStep()
    {
        PlayRandomOneShot(walkStepSoundNames);
    }


    // ���� �Ҹ� ���� ���
    public void PlayRandomJump()
    {
        PlayRandomOneShot(jumpSoundNames);
    }
}
