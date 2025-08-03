using UnityEngine;

public class CoinPickup : MonoBehaviour
{
    private bool isCollected = false;  // �� ���� ó���ϵ��� üũ
    private CoinManager coinManager;

    public void SetCoinManager(CoinManager manager)
    {
        coinManager = manager;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (isCollected) return;  // �̹� ó���Ǿ����� ����

        if (other.CompareTag("Player") || other.CompareTag("Ghost"))
        {
            if(other.CompareTag("Player"))
                SoundManager.Instance.PlayOneShotSound("Coin");

            isCollected = true;  // ���� ó�� ���� ���� �÷��� ����
            if (coinManager != null)
                coinManager.AddScore();

            Destroy(transform.gameObject); // ���� ������Ʈ ����
        }
    }
}