using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GhostManager : MonoBehaviour
{
    public GameObject ghostPrefab;

    // 누적 기록
    public List<List<Vector3>> ghostPositionLogs = new List<List<Vector3>>();
    public List<List<Quaternion>> ghostRotationLogs = new List<List<Quaternion>>();
    public List<List<int>> ghostStatusLogs = new List<List<int>>();
    public List<List<bool>> ghostFlipLogs = new List<List<bool>>();
    public List<List<string>> ghostAnimLogs = new List<List<string>>();

    private List<GhostReplayer> ghostInstances = new List<GhostReplayer>();

    public void SaveGhostTrack(
        List<Vector3> posLog,
        List<Quaternion> rotLog,
        List<int> statusLog,
        List<bool> flipLog,
        List<string> animLog)
    {
        ghostPositionLogs.Add(new List<Vector3>(posLog));
        ghostRotationLogs.Add(new List<Quaternion>(rotLog));
        ghostStatusLogs.Add(new List<int>(statusLog));
        ghostFlipLogs.Add(new List<bool>(flipLog));
        ghostAnimLogs.Add(new List<string>(animLog));
    }

    public void SpawnGhosts()
    {
        ClearGhosts();
        ghostInstances.Clear();

        for (int i = 0; i < ghostPositionLogs.Count; i++)
        {
            var ghost = Instantiate(ghostPrefab);
            ghost.tag = "Ghost";
            var replayer = ghost.GetComponent<GhostReplayer>();
            replayer.SetReplayData(
                new List<Vector3>(ghostPositionLogs[i]),
                new List<Quaternion>(ghostRotationLogs[i]),
                new List<int>(ghostStatusLogs[i]),
                new List<bool>(ghostFlipLogs[i]),
                new List<string>(ghostAnimLogs[i])
            );
            ghostInstances.Add(replayer);
        }

        StartCoroutine(BeginAllGhostsNextFrame());
    }

    private IEnumerator BeginAllGhostsNextFrame()
    {
        yield return null; // 딱 한 번! (or WaitForFixedUpdate)

        foreach (var ghost in ghostInstances)
            ghost.BeginReplay();
    }

    public void ClearGhosts()
    {
        foreach (var ghost in GameObject.FindGameObjectsWithTag("Ghost"))
            Destroy(ghost);
        ghostInstances.Clear();
    }

    public void ResetTracks()
    {
        ghostPositionLogs.Clear();
        ghostRotationLogs.Clear();
        ghostStatusLogs.Clear();
        ghostFlipLogs.Clear();
        ghostAnimLogs.Clear();
        ClearGhosts();
    }
}
