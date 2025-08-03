using UnityEngine;
using TMPro;

public class BlockHitCounter : MonoBehaviour
{
    [Header("설정")]
    public int maxCount = 3;
    public TextMeshPro countText;
    public string playerTag = "Player";
    public string cloneTag = "Clone";

    [Header("옵션")]
    public BoxCollider2D boxCollider;  // 카운트용 콜라이더 (필수)

    private int currentCount;
    private bool isBroken = false;

    void Awake()
    {
        if (boxCollider == null)
        {
            boxCollider = GetComponent<BoxCollider2D>();
            if (boxCollider == null)
                boxCollider = gameObject.AddComponent<BoxCollider2D>();
        }
    }

    void Start()
    {
        ResetCount();
    }

    void ResetCount()
    {
        currentCount = maxCount;
        isBroken = false;
        UpdateCountText();
        SetChildrenActive(true);
        if (boxCollider != null)
            boxCollider.enabled = true;
    }

    void UpdateCountText()
    {
        if (countText != null)
            countText.text = currentCount.ToString();
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (isBroken) return;

        if (collision.gameObject.CompareTag(playerTag) || collision.gameObject.CompareTag(cloneTag))
        {
            if (collision.gameObject.CompareTag(playerTag))
                SoundManager.Instance.PlayEffectSound("SFX_JumpBlock");
            if (currentCount > 0)
            {
                currentCount--;
                UpdateCountText();

                if (currentCount <= 0)
                {
                    isBroken = true;
                    SetChildrenActive(false);
                    if (boxCollider != null)
                        boxCollider.enabled = false;
                }
            }
        }
    }

    void SetChildrenActive(bool active)
    {
        for (int i = 0; i < transform.childCount; i++)
            transform.GetChild(i).gameObject.SetActive(active);
    }

    public void OnPlayerRespawn()
    {
        ResetCount();
    }
}