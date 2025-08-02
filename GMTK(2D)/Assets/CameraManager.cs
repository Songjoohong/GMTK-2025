using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class CameraManager : MonoBehaviour
{
    private CinemachineVirtualCamera camera;

    void Start()
    {
        camera = GetComponent<CinemachineVirtualCamera>();
    }

    void Update()
    {
        camera.Follow = GameManager.Instance.playerObject.gameObject.transform;
    }
}
