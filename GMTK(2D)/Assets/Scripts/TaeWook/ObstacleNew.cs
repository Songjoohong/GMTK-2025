using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObstacleNew : MonoBehaviour
{
    public enum ObstacleType
    {
        WildDog,
        Fire,
        Gear
    }

    [Header("��ֹ� Ÿ��")]
    public ObstacleType obstacleType;

    [Header("��� ����Ʈ ������")]
    public GameObject chickDeathEffectPrefab;
    public GameObject chickenDeathEffectPrefab;
    // defaultDeathEffectPrefab�� �� �̻� ������� �����Ƿ� �����մϴ�.

    [Header("��ü ������ (�鰳, �ҿ��� �ش�)")]
    public GameObject chickCorpsePrefab;
    public GameObject chickenCorpsePrefab;

    public float effectDuration = 1.0f;
    private bool isTriggered = false;

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (isTriggered) return;

        if (collision.gameObject.CompareTag("Player"))
        {
            var ghostManager = FindObjectOfType<GhostManager>();
            if (ghostManager == null) return;

            if (!ghostManager.TryStartPlayerDeath()) return;

            // ��ֹ� Ÿ�Կ� �´� ȿ���� ���� ó��
            HandleDeathByObstacle(collision.gameObject);

            // ���� ��� ������ ������ �����ϰ� ����
            StartCoroutine(DeathSequence_Player(collision.gameObject, ghostManager));
        }
        else if (collision.gameObject.CompareTag("Ghost"))
        {
            StartCoroutine(DeathSequence_Ghost(collision.gameObject));
        }
    }

    // ��ֹ� Ÿ�Կ� ���� ����Ʈ, ���� ���� ó���ϴ� �޼���
    private void HandleDeathByObstacle(GameObject player)
    {
        var characterStatus = player.GetComponent<CharacterStatus>();
        GameObject effectToUse = null;
        GameObject corpseToUse = null;

        // ��� ��ֹ� Ÿ�Կ� ���� �÷��̾��� ���¿� ���� ����Ʈ�� ����
        if (characterStatus != null)
        {
            if (characterStatus.currentStatus == CharacterStatus.Status.Chick)
            {
                effectToUse = chickDeathEffectPrefab;
            }
            else if (characterStatus.currentStatus == CharacterStatus.Status.Chicken)
            {
                effectToUse = chickenDeathEffectPrefab;
            }
        }

        switch (obstacleType)
        {
            case ObstacleType.Gear:
                // ���: ���º� ����Ʈ�� ����ϰ�, ���� ���
                SoundManager.Instance.PlayEffectSound("SFX_Death_Saw");
                break;

            case ObstacleType.Fire:
                // ��: ���º� ����Ʈ, ��ü, ���� ���
                SoundManager.Instance.PlayEffectSound("SFX_Death_Fire");
                if (characterStatus != null)
                {
                    if (characterStatus.currentStatus == CharacterStatus.Status.Chick)
                    {
                        corpseToUse = chickCorpsePrefab;
                    }
                    else if (characterStatus.currentStatus == CharacterStatus.Status.Chicken)
                    {
                        corpseToUse = chickenCorpsePrefab;
                    }
                }
                break;

            case ObstacleType.WildDog:
                // �鰳: ���º� ����Ʈ, ��ü, ���� ���
                SoundManager.Instance.PlayEffectSound("SFX_Death_Saw");
                if (characterStatus != null)
                {
                    if (characterStatus.currentStatus == CharacterStatus.Status.Chick)
                    {
                        corpseToUse = chickCorpsePrefab;
                    }
                    else if (characterStatus.currentStatus == CharacterStatus.Status.Chicken)
                    {
                        corpseToUse = chickenCorpsePrefab;
                    }
                }
                break;
        }

        // �Ҵ�� ����Ʈ�� �ִٸ� ����
        if (effectToUse != null)
        {
            Instantiate(effectToUse, player.transform.position, Quaternion.identity);
        }
        // �Ҵ�� ��ü �������� �ִٸ� ����
        if (corpseToUse != null)
        {
            Instantiate(corpseToUse, player.transform.position, Quaternion.identity);
        }
    }

    IEnumerator DeathSequence_Player(GameObject player, GhostManager ghostManager)
    {
        isTriggered = true;

        player.SetActive(false);

        yield return new WaitForSeconds(effectDuration);

        GhostRecorder ghostRecorder = player.GetComponent<GhostRecorder>();

        if (ghostRecorder != null && ghostManager != null)
        {
            ghostManager.SaveGhostTrack(
                new List<Vector3>(ghostRecorder.positionLog),
                new List<Quaternion>(ghostRecorder.rotationLog),
                new List<int>(ghostRecorder.statusLog),
                new List<bool>(ghostRecorder.flipLog),
                new List<string>(ghostRecorder.animLog)
            );
            ghostRecorder.Clear();
            ghostManager.SpawnGhosts();

            ghostManager.ResetBlocks();
        }

        Destroy(player);

        var gm = GameManager.Instance;
        if (gm != null && gm.playerPrefab != null)
        {
            var newPlayer = Instantiate(gm.playerPrefab, gm.spawnPos, Quaternion.identity);
            gm.playerObject = newPlayer;
        }

        ghostManager.EndPlayerDeath();
        isTriggered = false;
    }

    IEnumerator DeathSequence_Ghost(GameObject ghost)
    {
        // ��Ʈ�� ���°� �����Ƿ� �⺻ ����Ʈ �����ո� Ȯ��
        if (chickDeathEffectPrefab != null) // ��� ����Ʈ�� ����ϼ̴� chickDeathEffectPrefab�� ��Ʈ ����Ʈ�� ����մϴ�.
        {
            Instantiate(chickDeathEffectPrefab, ghost.transform.position, Quaternion.identity);
        }

        ghost.SetActive(false);
        yield return new WaitForSeconds(effectDuration);

        Destroy(ghost);
    }
}