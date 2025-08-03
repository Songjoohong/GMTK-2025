using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public Vector2 spawnPos;

    public GameObject playerPrefab;
    public GameObject clonePrefab;

    public GameObject playerObject;
    public List<GameObject> clones = new List<GameObject>();

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    void Start()
    {
        playerObject = Instantiate(playerPrefab);
        playerObject.transform.position = spawnPos;
    }

    public void PlayerDie()
    {
        GameObject player = Instantiate(playerPrefab);
        GameObject clone = Instantiate(clonePrefab);
        clone.GetComponent<InputReplayer>().GetInputLog(playerObject.GetComponent<PlayerInputRecorder>().inputLog);

        player.transform.position = spawnPos;
        clone.transform.position = spawnPos;

        clones.Add(clone);
        playerObject = player;

        Collider2D playerCollider = player.GetComponent<Collider2D>();
        foreach (GameObject obj in clones)
        {
            //Physics2D.IgnoreCollision(obj.GetComponent<Collider2D>(), playerCollider, true);
            obj.GetComponent<InputReplayer>().Replay(spawnPos);
        }
    }
}