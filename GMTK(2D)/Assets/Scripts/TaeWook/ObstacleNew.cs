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

    [Header("장애물 타입")]
    public ObstacleType obstacleType;

    [Header("사망 이펙트 프리팹")]
    public GameObject chickDeathEffectPrefab;
    public GameObject chickenDeathEffectPrefab;
    // defaultDeathEffectPrefab은 더 이상 사용하지 않으므로 제거합니다.

    [Header("시체 프리팹 (들개, 불에만 해당)")]
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

            // 장애물 타입에 맞는 효과를 먼저 처리
            HandleDeathByObstacle(collision.gameObject);

            // 실제 사망 로직은 기존과 동일하게 실행
            StartCoroutine(DeathSequence_Player(collision.gameObject, ghostManager));
        }
        else if (collision.gameObject.CompareTag("Ghost"))
        {
            StartCoroutine(DeathSequence_Ghost(collision.gameObject));
        }
    }

    // 장애물 타입에 따라 이펙트, 사운드 등을 처리하는 메서드
    private void HandleDeathByObstacle(GameObject player)
    {
        var characterStatus = player.GetComponent<CharacterStatus>();
        GameObject effectToUse = null;
        GameObject corpseToUse = null;

        // 모든 장애물 타입에 대해 플레이어의 상태에 따라 이펙트를 결정
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
                // 톱니: 상태별 이펙트만 사용하고, 사운드 재생
                SoundManager.Instance.PlayEffectSound("SFX_Death_Saw");
                break;

            case ObstacleType.Fire:
                // 불: 상태별 이펙트, 시체, 사운드 재생
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
                // 들개: 상태별 이펙트, 시체, 사운드 재생
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

        // 할당된 이펙트가 있다면 생성
        if (effectToUse != null)
        {
            Instantiate(effectToUse, player.transform.position, Quaternion.identity);
        }
        // 할당된 시체 프리팹이 있다면 생성
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
        // 고스트는 상태가 없으므로 기본 이펙트 프리팹만 확인
        if (chickDeathEffectPrefab != null) // 톱니 이펙트로 사용하셨던 chickDeathEffectPrefab을 고스트 이펙트로 사용합니다.
        {
            Instantiate(chickDeathEffectPrefab, ghost.transform.position, Quaternion.identity);
        }

        ghost.SetActive(false);
        yield return new WaitForSeconds(effectDuration);

        Destroy(ghost);
    }
}