using System.Collections.Generic;
using UnityEngine;

public class GhostReplayer : MonoBehaviour
{
    public List<Vector3> positionLog;
    public List<Quaternion> rotationLog;
    public List<int> statusLog;
    public List<bool> flipLog;
    public List<string> animLog;

    private int currentIndex = 0;
    private bool replayStarted = false;

    private SpriteRenderer spriteRenderer;
    private Animation animationComponent;

    public void SetReplayData(
        List<Vector3> posLog,
        List<Quaternion> rotLog,
        List<int> statusLogInput,
        List<bool> flipLogInput,
        List<string> animLogInput)
    {
        positionLog = posLog;
        rotationLog = rotLog;
        statusLog = statusLogInput;
        flipLog = flipLogInput;
        animLog = animLogInput;
        currentIndex = 0;
        replayStarted = false;
    }

    public void BeginReplay()
    {
        currentIndex = 0;
        replayStarted = true;
    }

    void FixedUpdate()
    {
        if (!replayStarted) return;
        if (positionLog == null || currentIndex >= positionLog.Count) return;

        transform.position = positionLog[currentIndex];
        transform.rotation = rotationLog[currentIndex];

        int stateIndex = statusLog != null && currentIndex < statusLog.Count ? statusLog[currentIndex] : 0;

        // �ڽ� Ȱ��ȭ/��Ȱ��ȭ
        for (int i = 0; i < transform.childCount; i++)
            transform.GetChild(i).gameObject.SetActive(i == stateIndex);

        // ���� ����
        if (stateIndex >= 0 && stateIndex < transform.childCount)
        {
            var child = transform.GetChild(stateIndex);
            spriteRenderer = child.GetComponent<SpriteRenderer>();
            animationComponent = child.GetComponent<Animation>();
        }
        else
        {
            spriteRenderer = null;
            animationComponent = null;
        }

        // Sprite ������ �ݿ�
        if (spriteRenderer != null && flipLog != null && currentIndex < flipLog.Count)
            spriteRenderer.flipX = flipLog[currentIndex];

        // [����!] �ִϸ��̼� ����ȭ + �����
        if (animationComponent != null && animLog != null && currentIndex < animLog.Count)
        {
            string logAnimName = animLog[currentIndex];
            if (!string.IsNullOrEmpty(logAnimName))
            {
                // ��ϵ� ��� AnimationState �̸� �����
                foreach (AnimationState state in animationComponent)
                {
                    Debug.Log($"[Replayer] Animation ������Ʈ ��� �̸�: {state.name}");
                }
                Debug.Log($"[Replayer] ���÷��̿��� ����Ϸ��� �̸�: {logAnimName}");

                if (animationComponent[logAnimName] != null)
                {
                    if (!animationComponent.IsPlaying(logAnimName))
                        animationComponent.CrossFade(logAnimName, 0.1f);
                }
                else
                {
                    Debug.LogWarning($"[Replayer] {logAnimName}��(��) Animation ������Ʈ�� ����!");
                }
            }
        }

        currentIndex++;
    }
}
