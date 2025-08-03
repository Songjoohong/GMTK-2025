using UnityEngine;

public class MultiToggleButton : MonoBehaviour
{
    [Header("����")]
    public string playerTag = "Player";
    public string ghostTag = "Ghost";

    [Header("������ Ȱ��ȭ �� ���� ������Ʈ��/��Ȱ��ȭ ���¿�����")]
    public GameObject[] targetObjects;

    [Header("�ڽ� ������Ʈ")]
    public GameObject pressedState;
    public GameObject unpressedState;

    private int pressingCount = 0;

    void Start()
    {
        UpdateButtonVisuals(false);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag(playerTag) || other.CompareTag(ghostTag))
        {
            pressingCount++;
            if (pressingCount == 1)
                SetTargetsActive(true);
            UpdateButtonVisuals(true);
            SoundManager.Instance.PlayOneShotSound("SFX_Door");
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag(playerTag) || other.CompareTag(ghostTag))
        {
            pressingCount = Mathf.Max(pressingCount - 1, 0);
            if (pressingCount == 0)
                SetTargetsActive(false);
            UpdateButtonVisuals(pressingCount > 0);
        }
    }

    void SetTargetsActive(bool active)
    {
        foreach (var obj in targetObjects)
        {
            if (obj != null)
                obj.SetActive(active);
        }
    }

    void UpdateButtonVisuals(bool isPressed)
    {
        if (pressedState != null)
            pressedState.SetActive(isPressed);

        if (unpressedState != null)
            unpressedState.SetActive(!isPressed);
    }
}