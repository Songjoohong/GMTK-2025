using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class CoinManager : MonoBehaviour
{
    [Header("코인 설정")]
    public GameObject coinPrefab;

    [Header("스폰 포인트 부모 (자동 할당용)")]
    public Transform spawnPointsParent;

    public List<Transform> spawnPoints = new List<Transform>();

    [Header("UI")]
    public TextMeshProUGUI scoreText;

    private List<GameObject> spawnedCoins = new List<GameObject>();
    private int score = 0;

    void Awake()
    {
        // spawnPointsParent가 있으면 자식들 위치 자동 할당
        if (spawnPointsParent != null)
        {
            spawnPoints.Clear();
            foreach (Transform child in spawnPointsParent)
            {
                spawnPoints.Add(child);
            }
        }
    }

    void Start()
    {
        SpawnAllCoins();
        UpdateScoreUI();
    }

    public void SpawnAllCoins()
    {
        ClearCoins();

        foreach (var point in spawnPoints)
        {
            GameObject coin = Instantiate(coinPrefab, point.position, Quaternion.identity);
            spawnedCoins.Add(coin);

            // CoinPickup 스크립트가 있다면 CoinManager 참조 넘기기
            var pickup = coin.GetComponentInChildren<CoinPickup>();
            if (pickup != null)
            {
                pickup.SetCoinManager(this);

                // 부모 위치로 보정(필요하면)
                coin.transform.position = point.position;
            }
        }
    }

    public void ClearCoins()
    {
        foreach (var coin in spawnedCoins)
        {
            if (coin != null)
                Destroy(coin);
        }
        spawnedCoins.Clear();
    }

    public void AddScore(int amount = 1)
    {
        score += amount;
        UpdateScoreUI();
    }

    private void UpdateScoreUI()
    {
        if (scoreText != null)
            scoreText.text = $"Score: {score}";
    }

    public void ResetScore()
    {
        score = 0;
        UpdateScoreUI();
    }
}
