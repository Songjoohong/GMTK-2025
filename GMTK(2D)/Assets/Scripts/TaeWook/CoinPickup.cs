using UnityEngine;

public class CoinPickup : MonoBehaviour
{
    private CoinManager coinManager;

    public void SetCoinManager(CoinManager manager)
    {
        coinManager = manager;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") || other.CompareTag("Ghost"))
        {
            if(other.CompareTag("Player"))
                SoundManager.Instance.PlayOneShotSound("Coin");
            if (coinManager != null) 
            {
                coinManager.AddScore();
            }

            Destroy(gameObject);
        }
    }
}