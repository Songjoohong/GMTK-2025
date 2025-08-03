using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestGhostKill : MonoBehaviour
{
    public GameObject playerPrefab;
    public Vector2 spawnPos;
    private GhostRecorder ghostRecorder;
    private GhostManager ghostManager;
    private bool canKill = true;

    void Start()
    {
        ghostRecorder = GetComponent<GhostRecorder>();
        ghostManager = FindObjectOfType<GhostManager>();
        if (ghostManager == null)
            Debug.LogError("GhostManager�� ���� �������� �ʽ��ϴ�!");
    }

    void Update()
    {
    }

    IEnumerator KillAndNextLoop()
    {
        // �� ��� ���� (�� ���� �÷����� �α׸�!)
        ghostManager.SaveGhostTrack(
            new List<Vector3>(ghostRecorder.positionLog),
            new List<Quaternion>(ghostRecorder.rotationLog),
            new List<int>(ghostRecorder.statusLog),
            new List<bool>(ghostRecorder.flipLog),
            new List<string>(ghostRecorder.animLog)
        );

        yield return null;

        // GhostRecorder �α׸� �ݵ�� Clear!!!
        ghostRecorder.Clear();

        // ��Ʈ ����/�÷��̾� ����
        ghostManager.SpawnGhosts();
        // ��� �ʱ�ȭ
        ghostManager.ResetBlocks();

        var player = Instantiate(playerPrefab, spawnPos, Quaternion.identity);
        GameManager.Instance.playerObject = player;

        yield return null;
        Destroy(gameObject);
    }
}