// SceneLoader.cs
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoader : MonoBehaviour
{
    public static SceneLoader Instance;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject); // 씬이 바뀌어도 파괴되지 않게
        }
        else
        {
            Destroy(gameObject);
        }
    }

    // 씬 이름을 받아 씬을 로드하는 public 메서드
    public void LoadScene(string sceneName)
    {
        if (string.IsNullOrEmpty(sceneName))
        {
            Debug.LogError("로드할 씬의 이름이 지정되지 않았습니다.");
            return;
        }

        SceneManager.LoadScene(sceneName);
    }
}