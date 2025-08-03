using UnityEngine;

public class CoinPickup : MonoBehaviour
{
    private bool isCollected = false;  // 한 번만 처리하도록 체크
    private CoinManager coinManager;

    public void SetCoinManager(CoinManager manager)
    {
        coinManager = manager;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (isCollected) return;  // 이미 처리되었으면 무시

        if (other.CompareTag("Player") || other.CompareTag("Ghost"))
        {
            if(other.CompareTag("Player"))
                SoundManager.Instance.PlayOneShotSound("Coin");

            isCollected = true;  // 점수 처리 막기 위해 플래그 설정
            if (coinManager != null)
                coinManager.AddScore();

            Destroy(transform.gameObject); // 코인 오브젝트 제거
        }
    }
}