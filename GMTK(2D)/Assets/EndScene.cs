using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndScene : MonoBehaviour
{
    [Header("이동할 씬 이름")]
    [Tooltip("인스펙터에서 이동할 씬의 이름을 입력하세요.")]
    public string endingSceneName;

    // 플레이어가 OnTriggerEnter2D에 닿았을 때 호출
    private void OnTriggerEnter2D(Collider2D other)
    {
        // 충돌한 오브젝트의 태그가 "Player"인지 확인
        if (other.CompareTag("Player"))
        {
            Debug.Log("플레이어가 엔딩 트리거에 닿았습니다. 씬 이동 시작.");

            // SceneLoader의 인스턴스를 통해 씬 로드
            if (SceneLoader.Instance != null)
            {
                SceneLoader.Instance.LoadScene(endingSceneName);
            }
            else
            {
                Debug.LogError("SceneLoader 인스턴스를 찾을 수 없습니다. 씬 이동 실패.");
            }
        }
    }
}
