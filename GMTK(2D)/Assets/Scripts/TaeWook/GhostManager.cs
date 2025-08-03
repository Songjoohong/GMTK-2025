using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GhostManager : MonoBehaviour
{
    public GameObject ghostPrefab;

    // ���� ���
    public List<List<Vector3>> ghostPositionLogs = new List<List<Vector3>>();
    public List<List<Quaternion>> ghostRotationLogs = new List<List<Quaternion>>();
    public List<List<int>> ghostStatusLogs = new List<List<int>>();
    public List<List<bool>> ghostFlipLogs = new List<List<bool>>();
    public List<List<string>> ghostAnimLogs = new List<List<string>>();

    private List<GhostReplayer> ghostInstances = new List<GhostReplayer>();

    // �÷��̾� ���� ó�� ������ �÷���
    private bool isPlayerDying = false;
    private int tryCount = 1;
    public GameObject centerText;

    public bool IsPlayerDying()
    {
        return isPlayerDying;
    }

    private void SetPlayerDying(bool dying)
    {
        isPlayerDying = dying;
    }

    public void SaveGhostTrack(
        List<Vector3> posLog,
        List<Quaternion> rotLog,
        List<int> statusLog,
        List<bool> flipLog,
        List<string> animLog)
    {
        ghostPositionLogs.Add(new List<Vector3>(posLog));
        ghostRotationLogs.Add(new List<Quaternion>(rotLog));
        ghostStatusLogs.Add(new List<int>(statusLog));
        ghostFlipLogs.Add(new List<bool>(flipLog));
        ghostAnimLogs.Add(new List<string>(animLog));
    }

    public void SpawnGhosts()
    {
        GameManager.Instance.ResetDog();

        ClearGhosts();
        ghostInstances.Clear();

        for (int i = 0; i < ghostPositionLogs.Count; i++)
        {
            var ghost = Instantiate(ghostPrefab);
            ghost.tag = "Ghost";
            var replayer = ghost.GetComponent<GhostReplayer>();
            replayer.SetReplayData(
                new List<Vector3>(ghostPositionLogs[i]),
                new List<Quaternion>(ghostRotationLogs[i]),
                new List<int>(ghostStatusLogs[i]),
                new List<bool>(ghostFlipLogs[i]),
                new List<string>(ghostAnimLogs[i])
            );
            ghostInstances.Add(replayer);
        }

        StartCoroutine(BeginAllGhostsNextFrame());

        tryCount++;
        centerText.GetComponent<CenterTextController>().ShowText(tryCount);
    }

    private IEnumerator BeginAllGhostsNextFrame()
    {
        yield return null; // �� �� ��! (or WaitForFixedUpdate)

        foreach (var ghost in ghostInstances)
            ghost.BeginReplay();
    }

    public void ClearGhosts()
    {
        foreach (var ghost in GameObject.FindGameObjectsWithTag("Ghost"))
            Destroy(ghost);
        ghostInstances.Clear();
    }


    public void ResetBlocks()
    {
        var blocks = FindObjectsOfType<BlockHitCounter>();
        foreach (var block in blocks)
        {
            block.OnPlayerRespawn();
        }

        // CoinManager �ν��Ͻ� ã�Ƽ� ResetCoins ȣ��
        var coinManager = FindObjectOfType<CoinManager>();
        coinManager.SpawnAllCoins();
        coinManager.ResetScore();

        // MushroomManager �ν��Ͻ� ã�Ƽ� RestMushrooms ȣ��
        var mushroomManager = FindObjectOfType<MushroomManager>();
        mushroomManager.ResetMushrooms();

        var movers = FindObjectsOfType<MoverNew>();
        foreach (var mover in movers)
        {
            mover.ResetMover();
        }

    }

    // �÷��̾� ���� ó�� ����
    public bool TryStartPlayerDeath()
    {
        if (isPlayerDying)
            return false;

        isPlayerDying = true;
        return true;
    }

    // �÷��̾� ���� ó�� �Ϸ�
    public void EndPlayerDeath()
    {
        isPlayerDying = false;
        GameManager.Instance.life--;
        if (GameManager.Instance.life == 0)
        {
            SceneManager.LoadScene("GameOverScene");
        }
    }
}
