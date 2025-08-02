using System.Collections.Generic;
using UnityEngine;

public class GhostRecorder : MonoBehaviour
{
    public List<Vector3> positionLog = new List<Vector3>();
    public List<Quaternion> rotationLog = new List<Quaternion>();
    public List<int> statusLog = new List<int>();
    public List<bool> flipLog = new List<bool>();
    public List<string> animLog = new List<string>();

    private SpriteRenderer spriteRenderer;
    private Animation animationComponent;

    void FixedUpdate()
    {
        positionLog.Add(transform.position);
        rotationLog.Add(transform.rotation);

        var charStatus = GetComponent<CharacterStatus>();
        int stateIndex = (int)charStatus.currentStatus;
        statusLog.Add(stateIndex);

        UpdateRefs(stateIndex);

        flipLog.Add(spriteRenderer != null ? spriteRenderer.flipX : false);

        // 수정된 부분!
        string animName = GetCurrentPlayingAnimationName(animationComponent);
        animLog.Add(animName);

        if (!string.IsNullOrEmpty(animName))
            Debug.Log($"[Recorder] 기록된 애니메이션 이름: {animName}");
    }

    string GetCurrentPlayingAnimationName(Animation anim)
    {
        if (anim == null) return "";
        foreach (AnimationState state in anim)
        {
            if (anim.IsPlaying(state.name))
                return state.name;
        }
        return "";
    }


    void UpdateRefs(int stateIndex)
    {
        if (stateIndex < 0 || stateIndex >= transform.childCount)
        {
            spriteRenderer = null;
            animationComponent = null;
            return;
        }
        var child = transform.GetChild(stateIndex);
        spriteRenderer = child.GetComponent<SpriteRenderer>();
        animationComponent = child.GetComponent<Animation>();
    }

    public void Clear()
    {
        positionLog.Clear();
        rotationLog.Clear();
        statusLog.Clear();
        flipLog.Clear();
        animLog.Clear();
    }
}