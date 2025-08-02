using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObstacleNew : MonoBehaviour
{
    public GameObject deathEffectPrefab;
    public float effectDuration = 1.0f;
    private bool isTriggered = false;

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (isTriggered) return;

        // 플레이어 or 고스트 모두 감지
        if (collision.gameObject.CompareTag("Player"))
        {
            isTriggered = true;
            StartCoroutine(DeathSequence_Player(collision.gameObject));
        }
        else if (collision.gameObject.CompareTag("Ghost"))
        {
            // 고스트(클론)도 죽음 이펙트 + 삭제
            StartCoroutine(DeathSequence_Ghost(collision.gameObject));
        }
    }

    IEnumerator DeathSequence_Player(GameObject player)
    {
        GameObject effect = Instantiate(deathEffectPrefab, player.transform.position, Quaternion.identity);
        player.SetActive(false);

        yield return new WaitForSeconds(effectDuration);

        Destroy(effect);

        // 플레이어 기록, 고스트 생성
        GhostRecorder ghostRecorder = player.GetComponent<GhostRecorder>();
        GhostManager ghostManager = FindObjectOfType<GhostManager>();

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
        }

        Destroy(player);

        var gm = GameManager.Instance;
        if (gm != null && gm.playerPrefab != null)
        {
            var newPlayer = Instantiate(gm.playerPrefab, gm.spawnPos, Quaternion.identity);
            gm.playerObject = newPlayer;
        }
        isTriggered = false;
    }

    IEnumerator DeathSequence_Ghost(GameObject ghost)
    {
        GameObject effect = Instantiate(deathEffectPrefab, ghost.transform.position, Quaternion.identity);
        ghost.SetActive(false);

        yield return new WaitForSeconds(effectDuration);

        Destroy(effect);
        Destroy(ghost);
    }
}