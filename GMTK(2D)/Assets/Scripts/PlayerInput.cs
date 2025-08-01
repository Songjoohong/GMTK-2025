using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInput : MonoBehaviour
{
    public string moveAxisName;
    public string jumpName;
    public float move { get; private set; }
    public bool jump { get; private set; }

    void Start()
    {

    }

    void Update()
    {
        move = Input.GetAxis(moveAxisName);
        jump = Input.GetButton(jumpName);
    }
}
