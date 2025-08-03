using UnityEngine;

public class CoinPickup : MonoBehaviour
{
    private bool isCollected = false; // 한 번만 처리하도록 체크
    private CoinManager coinManager;

    public GameObject collectEffectPrefab; // 코인 수집 이펙트 프리팹
    public float effectDuration = 1.0f; // 이펙트 지속시간

    public void SetCoinManager(CoinManager manager)
    {
        coinManager = manager;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (isCollected) return; // 이미 처리되었으면 무시

        if (other.CompareTag("Player") || other.CompareTag("Ghost"))
        {
            if (other.CompareTag("Player"))
                SoundManager.Instance.PlayOneShotSound("Coin");

            isCollected = true; // 점수 처리 막기 위해 플래그 설정
            if (coinManager != null)
                coinManager.AddScore();

            // 이펙트 재생 및 코인 제거 처리
            if (collectEffectPrefab != null)
            {
                GameObject effect = Instantiate(collectEffectPrefab, transform.position, Quaternion.identity);
                Destroy(effect, effectDuration);
            }

            Destroy(gameObject); // 코인 오브젝트 파괴
        }
    }
}