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

    // ��� ������ AudioSource ã�� (Ǯ��)
    private AudioSource GetAvailableAudioSource()
    {
        foreach (var src in audioSourcePool)
        {
            if (!src.isPlaying)
                return src;
        }
        // �����ϸ� ���� ����
        AudioSource newSrc = Instantiate(audioSourcePrefab, transform);
        newSrc.playOnAwake = false;
        audioSourcePool.Add(newSrc);
        return newSrc;
    }

    // �̸����� UI ���� ���
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

    // �̸����� BGM ���
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

    // �̸����� �ܹ߼� ȿ���� ���
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

    // �̸����� ���� ȿ���� ���� ��� (Ǯ�� Ȱ��)
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
}
