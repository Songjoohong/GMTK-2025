using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PlayerInput : MonoBehaviour
{
    public string moveAxisName;
    public string jumpName;
    public string interactionName;
    public float move { get; private set; }
    public bool jump { get; private set; }
    public bool jumpPressed { get; private set; }
    public bool interaction { get; private set; }

    void Start()
    {

    }

    void Update()
    {
        move = Input.GetAxisRaw(moveAxisName);
        jump = Input.GetButton(jumpName);
        jumpPressed = Input.GetButtonDown(jumpName);
        interaction = Input.GetButton(interactionName);
    }
}
