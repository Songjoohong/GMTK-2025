using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public Vector2 spawnPos;

    public GameObject playerPrefab;
    public GameObject clonePrefab;
    public GameObject dogPrefab;

    public GameObject playerObject;
    public GameObject dogObject;
    public List<GameObject> clones = new List<GameObject>();

    public float timer = 0;
    public float waitTime = 2f;
    private float elapsedTime = 0f;
    private bool dogSpawn;

    public int life = 7;

    public int tryCount = 1;

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

    void Update()
    {
        timer += Time.deltaTime;
        elapsedTime += Time.deltaTime;

        if (elapsedTime >= waitTime && !dogSpawn)
        {
            dogObject = Instantiate(dogPrefab);
            dogObject.transform.position = spawnPos;
            dogObject.GetComponent<EnemyChase>().target = playerObject.transform;
            dogSpawn = true;
        }
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

    public void ResetDog()
    {
        Destroy(dogObject);
        elapsedTime = 0;
        dogSpawn = false;
    }
}