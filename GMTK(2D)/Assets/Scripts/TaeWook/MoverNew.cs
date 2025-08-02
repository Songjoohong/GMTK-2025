using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum MovementType
{
    Line,   // 0��1��2��1��0
    Cycle   // 0��1��2��0��1
}

public class MoverNew : MonoBehaviour
{
    [Header("Positions / Waypoints")]
    public Transform[] positions;          // ��� ������ (�ڽ� ������Ʈ��)

    [Header("Movement Settings")]
    public MovementType movementType = MovementType.Line;
    public float moveSpeed = 2f;           // �ӵ� (�ʴ� �Ÿ�)

    [Header("Start Position Settings")]
    public Transform startPos;             // ���� ��ġ (optional)
    [Tooltip("startPos���� ���� �̵��� positions �迭 �� ��ǥ �ε���")]
    public int startGoalIndex = 0;

    private int currIdx;
    private int dir = 1;
    private Vector3[] pathPoints;          // positions ��ġ ������

    void Start()
    {
        if (positions == null || positions.Length == 0) return;

        // positions ��ġ ���� (��Ÿ�� �� ���� ����)
        pathPoints = new Vector3[positions.Length];
        for (int i = 0; i < positions.Length; i++)
            pathPoints[i] = positions[i].position;

        StartCoroutine(MoveRoutine());
    }

    IEnumerator MoveRoutine()
    {
        // 1. startPos �� startGoalIndex ��ġ�� ���� �̵�
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
            // startPos ������ positions[0]���� ����
            currIdx = 0;
            transform.position = pathPoints[currIdx];
        }

        // 2. ��� ���� �ݺ� ����
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
        else // Line loop (�պ�)
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

    // �� �信�� ��ο� ����Ʈ ǥ�ÿ�
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

        // startPos ǥ��
        if (startPos != null)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(startPos.position, 0.25f);
        }
    }
}
