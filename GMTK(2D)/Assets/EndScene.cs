using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndScene : MonoBehaviour
{
    [Header("�̵��� �� �̸�")]
    [Tooltip("�ν����Ϳ��� �̵��� ���� �̸��� �Է��ϼ���.")]
    public string endingSceneName;

    // �÷��̾ OnTriggerEnter2D�� ����� �� ȣ��
    private void OnTriggerEnter2D(Collider2D other)
    {
        // �浹�� ������Ʈ�� �±װ� "Player"���� Ȯ��
        if (other.CompareTag("Player"))
        {
            Debug.Log("�÷��̾ ���� Ʈ���ſ� ��ҽ��ϴ�. �� �̵� ����.");

            // SceneLoader�� �ν��Ͻ��� ���� �� �ε�
            if (SceneLoader.Instance != null)
            {
                SceneLoader.Instance.LoadScene(endingSceneName);
            }
            else
            {
                Debug.LogError("SceneLoader �ν��Ͻ��� ã�� �� �����ϴ�. �� �̵� ����.");
            }
        }
    }
}
