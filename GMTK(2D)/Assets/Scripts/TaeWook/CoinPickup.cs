using UnityEngine;

public class CoinPickup : MonoBehaviour
{
    private bool isCollected = false; // �� ���� ó���ϵ��� üũ
    private CoinManager coinManager;

    public GameObject collectEffectPrefab; // ���� ���� ����Ʈ ������
    public float effectDuration = 1.0f; // ����Ʈ ���ӽð�

    public void SetCoinManager(CoinManager manager)
    {
        coinManager = manager;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (isCollected) return; // �̹� ó���Ǿ����� ����

        if (other.CompareTag("Player") || other.CompareTag("Ghost"))
        {
            if (other.CompareTag("Player"))
                SoundManager.Instance.PlayOneShotSound("Coin");

            isCollected = true; // ���� ó�� ���� ���� �÷��� ����
            if (coinManager != null)
                coinManager.AddScore();

            // ����Ʈ ��� �� ���� ���� ó��
            if (collectEffectPrefab != null)
            {
                GameObject effect = Instantiate(collectEffectPrefab, transform.position, Quaternion.identity);
                Destroy(effect, effectDuration);
            }

            Destroy(gameObject); // ���� ������Ʈ �ı�
        }
    }
}