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
        if (collision.gameObject.CompareTag("Player"))
        {
            var ghostManager = FindObjectOfType<GhostManager>();
            if (ghostManager == null) return;

            if (!ghostManager.TryStartPlayerDeath()) return; // 이미 죽음 처리 중이면 무시

            StartCoroutine(DeathSequence_Player(collision.gameObject, ghostManager));
        }
        else if (collision.gameObject.CompareTag("Ghost"))
        {
            StartCoroutine(DeathSequence_Ghost(collision.gameObject));
        }
    }

    IEnumerator DeathSequence_Player(GameObject player, GhostManager ghostManager)
    {
        GameObject effect = Instantiate(deathEffectPrefab, player.transform.position, Quaternion.identity);
        player.SetActive(false);

        yield return new WaitForSeconds(effectDuration);

        Destroy(effect);

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
