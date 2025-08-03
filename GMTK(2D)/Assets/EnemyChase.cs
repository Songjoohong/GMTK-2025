using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyChase : MonoBehaviour
{
    private DogController dogController; // ����
    public Transform target; // �÷��̾�
    public List<Vector3> targetPositionLog = new List<Vector3>();
    private int index = 0;

    void Awake()
    {
        dogController = GetComponent<DogController>();
    }

    void FixedUpdate()
    {
        targetPositionLog = target.GetComponent<GhostRecorder>().positionLog;
        transform.position = targetPositionLog[index];

        index++;
    }

}
