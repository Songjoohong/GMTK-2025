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
            Debug.LogError("GhostManager가 씬에 존재하지 않습니다!");
    }

    void Update()
    {
    }

    IEnumerator KillAndNextLoop()
    {
        // 내 기록 저장 (딱 현재 플레이한 로그만!)
        ghostManager.SaveGhostTrack(
            new List<Vector3>(ghostRecorder.positionLog),
            new List<Quaternion>(ghostRecorder.rotationLog),
            new List<int>(ghostRecorder.statusLog),
            new List<bool>(ghostRecorder.flipLog),
            new List<string>(ghostRecorder.animLog)
        );

        yield return null;

        // GhostRecorder 로그를 반드시 Clear!!!
        ghostRecorder.Clear();

        // 고스트 생성/플레이어 생성
        ghostManager.SpawnGhosts();
        // 블록 초기화
        ghostManager.ResetBlocks();

        var player = Instantiate(playerPrefab, spawnPos, Quaternion.identity);
        GameManager.Instance.playerObject = player;

        yield return null;
        Destroy(gameObject);
    }
}