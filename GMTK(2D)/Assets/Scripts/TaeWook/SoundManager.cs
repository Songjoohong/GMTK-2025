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
    public AudioSource audioSourcePrefab; // 빈 AudioSource 프리팹
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

        // Resources/Sounds 폴더에서 모든 AudioClip 로드
        AudioClip[] clips = Resources.LoadAll<AudioClip>("Sounds");
        clipDict.Clear();
        foreach (var clip in clips)
        {
            if (!clipDict.ContainsKey(clip.name))
                clipDict.Add(clip.name, clip);
        }

        // AudioSource 풀 초기화
        for (int i = 0; i < poolSize; i++)
        {
            AudioSource src = Instantiate(audioSourcePrefab, transform);
            src.playOnAwake = false;
            audioSourcePool.Add(src);
        }
    }

    // 사용 가능한 AudioSource 찾기 (풀링)
    private AudioSource GetAvailableAudioSource()
    {
        foreach (var src in audioSourcePool)
        {
            if (!src.isPlaying)
                return src;
        }
        // 부족하면 새로 생성
        AudioSource newSrc = Instantiate(audioSourcePrefab, transform);
        newSrc.playOnAwake = false;
        audioSourcePool.Add(newSrc);
        return newSrc;
    }

    // 이름으로 UI 사운드 재생
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

    // 이름으로 BGM 재생
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

    // 이름으로 단발성 효과음 재생
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

    // 이름으로 여러 효과음 동시 재생 (풀링 활용)
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
