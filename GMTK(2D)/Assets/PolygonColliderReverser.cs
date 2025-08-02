using UnityEngine;

[ExecuteInEditMode] // �����Ϳ����� ����ǰ�
public class PolygonColliderReverser : MonoBehaviour
{
    public bool reverse = false; // �ν����� üũ�ڽ�
    private bool lastReverseState = false;

    private PolygonCollider2D polygon;

    void OnValidate()
    {
        polygon = GetComponent<PolygonCollider2D>();
        if (polygon == null) return;

        // ���°� �ٲ� ��츸 ó��
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
                path[j].y *= -1f; // Y�� ����
            }
            polygon.SetPath(i, path);
        }

    }
}
