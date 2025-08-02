using UnityEngine;

[ExecuteInEditMode] // 에디터에서도 적용되게
public class PolygonColliderReverser : MonoBehaviour
{
    public bool reverse = false; // 인스펙터 체크박스
    private bool lastReverseState = false;

    private PolygonCollider2D polygon;

    void OnValidate()
    {
        polygon = GetComponent<PolygonCollider2D>();
        if (polygon == null) return;

        // 상태가 바뀐 경우만 처리
        if (reverse != lastReverseState)
        {
            FlipColliderY();
            lastReverseState = reverse;
        }
    }

    void FlipColliderY()
    {
        for (int i = 0; i < polygon.pathCount; i++)
        {
            Vector2[] path = polygon.GetPath(i);
            for (int j = 0; j < path.Length; j++)
            {
                path[j].y *= -1f; // Y축 반전
            }
            polygon.SetPath(i, path);
        }

    }
}
