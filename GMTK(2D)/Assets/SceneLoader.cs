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
            DontDestroyOnLoad(gameObject); // ���� �ٲ� �ı����� �ʰ�
        }
        else
        {
            Destroy(gameObject);
        }
    }

    // �� �̸��� �޾� ���� �ε��ϴ� public �޼���
    public void LoadScene(string sceneName)
    {
        if (string.IsNullOrEmpty(sceneName))
        {
            Debug.LogError("�ε��� ���� �̸��� �������� �ʾҽ��ϴ�.");
            return;
        }

        SceneManager.LoadScene(sceneName);
    }
}