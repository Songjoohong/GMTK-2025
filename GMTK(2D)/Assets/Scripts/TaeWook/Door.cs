using UnityEngine;

public class Door : MonoBehaviour
{
    [Header("��������Ʈ")]
    public Sprite openSprite;
    public Sprite closeSprite;

    [Header("����� ��")]
    public Door connectedDoor;

    [Header("�±�")]
    public string playerTag = "Player";

    [Header("���� ǥ�ÿ� �ڽĵ� (Ȱ��=����, ��Ȱ��=����)")]
    public GameObject[] indicators;

    private SpriteRenderer spriteRenderer;
    private bool lastIndicatorState;
    private bool lastConnectedDoorState = false;

    private bool playerInside = false;

    void Start()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        lastIndicatorState = AreAllIndicatorsActive();
        lastConnectedDoorState = connectedDoor != null && connectedDoor.IsOpen();
        UpdateDoorState();
    }

    void Update()
    {
        bool currentIndicatorState = AreAllIndicatorsActive();
        if (currentIndicatorState != lastIndicatorState)
        {
            UpdateDoorState();
            lastIndicatorState = currentIndicatorState;

            if (playerInside)
                TryTeleport();
        }

        bool currentConnectedState = connectedDoor != null && connectedDoor.IsOpen();
        if (currentConnectedState != lastConnectedDoorState)
        {
            lastConnectedDoorState = currentConnectedState;

            if (playerInside)
                TryTeleport();
        }
    }

    bool AreAllIndicatorsActive()
    {
        if (indicators == null || indicators.Length == 0) return false;

        foreach (var indicator in indicators)
        {
            if (indicator == null || !indicator.activeSelf)
                return false;
        }
        return true;
    }

    public void UpdateDoorState()
    {
        bool isOpen = AreAllIndicatorsActive();
        if (spriteRenderer != null)
            spriteRenderer.sprite = isOpen ? openSprite : closeSprite;
        if (isOpen && !lastIndicatorState)
        {
            SoundManager.Instance.PlayOneShotSound("SFX_DoorOpen");  // �� ���� �� ����
        }
        else if (!isOpen && lastIndicatorState)
        {
            SoundManager.Instance.PlayOneShotSound("SFX_DoorClose"); // �� ���� �� ����
        }
    }

    public bool IsOpen()
    {
        return AreAllIndicatorsActive();
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (!collision.CompareTag(playerTag)) return;

        playerInside = true;
        TryTeleport(collision);
    }

    void OnTriggerExit2D(Collider2D collision)
    {
        if (!collision.CompareTag(playerTag)) return;

        playerInside = false;
    }

    void TryTeleport(Collider2D collision = null)
    {
        if (!TeleportManager.Instance.CanTeleport()) return;
        if (!IsOpen()) return;
        if (connectedDoor == null || !connectedDoor.IsOpen()) return;

        Transform playerTransform = collision != null ? collision.transform : FindPlayerInTrigger();
        if (playerTransform == null) return;

        playerTransform.position = connectedDoor.transform.position;

        var rb = playerTransform.GetComponent<Rigidbody2D>();
        if (rb != null)
            rb.velocity = Vector2.zero;

        TeleportManager.Instance.StartTeleportCooldown(this);
    }

    Transform FindPlayerInTrigger()
    {
        Collider2D[] hits = Physics2D.OverlapPointAll(transform.position);
        foreach (var hit in hits)
        {
            if (hit.CompareTag(playerTag))
            {
                return hit.transform;
            }
                
        }
        return null;
    }
}
//SoundManager.Instance.PlayOneShotSound("SFX_Door");