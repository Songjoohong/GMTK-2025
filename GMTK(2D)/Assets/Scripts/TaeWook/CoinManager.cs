using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class CoinManager : MonoBehaviour
{
    [Header("���� ����")]
    public GameObject coinPrefab;

    [Header("���� ����Ʈ �θ� (�ڵ� �Ҵ��)")]
    public Transform spawnPointsParent;

    public List<Transform> spawnPoints = new List<Transform>();

    [Header("UI")]
    public TextMeshProUGUI scoreText;

    private List<GameObject> spawnedCoins = new List<GameObject>();
    private int score = 0;

    void Awake()
    {
        // spawnPointsParent�� ������ �ڽĵ� ��ġ �ڵ� �Ҵ�
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

            // CoinPickup ��ũ��Ʈ�� �ִٸ� CoinManager ���� �ѱ��
            var pickup = coin.GetComponentInChildren<CoinPickup>();
            if (pickup != null)
            {
                pickup.SetCoinManager(this);

                // �θ� ��ġ�� ����(�ʿ��ϸ�)
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
