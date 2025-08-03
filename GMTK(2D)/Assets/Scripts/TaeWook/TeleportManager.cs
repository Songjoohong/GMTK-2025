using System.Collections;
using UnityEngine;

public class TeleportManager : MonoBehaviour
{
    public static TeleportManager Instance { get; private set; }

    private bool isTeleporting = false;
    public float teleportCooldown = 1f;

    void Awake()
    {
        if (Instance != null && Instance != this)
            Destroy(gameObject);
        else
            Instance = this;
    }

    public bool CanTeleport()
    {
        return !isTeleporting;
    }

    public void StartTeleportCooldown(MonoBehaviour owner)
    {
        SoundManager.Instance.PlayOneShotSound("SFX_Door_In");
        owner.StartCoroutine(TeleportCooldownRoutine());
    }

    private IEnumerator TeleportCooldownRoutine()
    {
        isTeleporting = true;
        yield return new WaitForSeconds(teleportCooldown);
        isTeleporting = false;
    }
}