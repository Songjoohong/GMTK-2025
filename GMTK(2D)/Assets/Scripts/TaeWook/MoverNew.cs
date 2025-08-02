using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum MovementType
{
    Line,   // 0→1→2→1→0
    Cycle   // 0→1→2→0→1
}

public class MoverNew : MonoBehaviour
{
    [Header("Positions / Waypoints")]
    public Transform[] positions;          // 경로 지점들 (자식 오브젝트들)

    [Header("Movement Settings")]
    public MovementType movementType = MovementType.Line;
    public float moveSpeed = 2f;           // 속도 (초당 거리)

    [Header("Start Position Settings")]
    public Transform startPos;             // 시작 위치 (optional)
    [Tooltip("startPos에서 먼저 이동할 positions 배열 내 목표 인덱스")]
    public int startGoalIndex = 0;

    private int currIdx;
    private int dir = 1;
    private Vector3[] pathPoints;          // positions 위치 복제본

    void Start()
    {
        if (positions == null || positions.Length == 0) return;

        // positions 위치 복사 (런타임 중 변경 방지)
        pathPoints = new Vector3[positions.Length];
        for (int i = 0; i < positions.Length; i++)
            pathPoints[i] = positions[i].position;

        StartCoroutine(MoveRoutine());
    }

    IEnumerator MoveRoutine()
    {
        // 1. startPos → startGoalIndex 위치로 먼저 이동
        if (startPos != null && startGoalIndex >= 0 && startGoalIndex < pathPoints.Length)
        {
            Vector3 start = startPos.position;
            Vector3 end = pathPoints[startGoalIndex];
            float t = 0f;

            while (t < 1f)
            {
                t += Time.deltaTime * moveSpeed / Vector3.Distance(start, end);
                transform.position = Vector3.Lerp(start, end, t);
                yield return null;
            }

            transform.position = end;
            currIdx = startGoalIndex;
        }
        else
        {
            // startPos 없으면 positions[0]부터 시작
            currIdx = 0;
            transform.position = pathPoints[currIdx];
        }

        // 2. 경로 루프 반복 시작
        while (true)
        {
            int nextIdx = GetNextIndex();

            Vector3 start = pathPoints[currIdx];
            Vector3 end = pathPoints[nextIdx];
            float t = 0f;

            while (t < 1f)
            {
                t += Time.deltaTime * moveSpeed / Vector3.Distance(start, end);
                transform.position = Vector3.Lerp(start, end, t);
                yield return null;
            }

            transform.position = end;
            currIdx = nextIdx;
        }
    }

    int GetNextIndex()
    {
        if (movementType == MovementType.Cycle)
        {
            int next = currIdx + 1;
            if (next >= pathPoints.Length) next = 0;
            return next;
        }
        else // Line loop (왕복)
        {
            int next = currIdx + dir;
            if (next >= pathPoints.Length)
            {
                dir = -1;
                next = currIdx + dir;
            }
            else if (next < 0)
            {
                dir = 1;
                next = currIdx + dir;
            }
            return next;
        }
    }

    // 씬 뷰에서 경로와 포인트 표시용
    void OnDrawGizmos()
    {
        if (positions == null || positions.Length == 0) return;

        Gizmos.color = Color.cyan;
        for (int i = 0; i < positions.Length - 1; i++)
            if (positions[i] != null && positions[i + 1] != null)
                Gizmos.DrawLine(positions[i].position, positions[i + 1].position);

        if (movementType == MovementType.Cycle && positions.Length > 1 && positions[0] != null && positions[^1] != null)
            Gizmos.DrawLine(positions[positions.Length - 1].position, positions[0].position);

        Gizmos.color = Color.yellow;
        foreach (var pos in positions)
            if (pos != null)
                Gizmos.DrawSphere(pos.position, 0.15f);

        // startPos 표시
        if (startPos != null)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(startPos.position, 0.25f);
        }
    }
}
