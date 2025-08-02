using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PlayerInput : MonoBehaviour
{
    public string moveAxisName;
    public string jumpName;
    public string interactionName;

    public CharacterInput input;

    void Start()
    {
        input = new CharacterInput();
    }

    void Update()
    {
        input.move = Input.GetAxisRaw(moveAxisName);
        input.jump = Input.GetButton(jumpName);
        input.interaction = Input.GetButton(interactionName);
    }
}
