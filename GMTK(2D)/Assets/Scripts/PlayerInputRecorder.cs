using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PlayerInputRecorder : MonoBehaviour
{
    private PlayerInput playerInput;
    public List<InputRecord> inputLog = new List<InputRecord>();
    private float deltaTime = 0f;
    private float previousMove = 0;
    private bool previousJump = false;

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
    }

    void FixedUpdate()
    {
        deltaTime = Time.fixedDeltaTime;
        float move = playerInput.move;
        bool jump = playerInput.jump;
        bool interaction = playerInput.interaction;

        if (inputLog.Count == 0)
        {
            inputLog.Add(new InputRecord
            {
                time = deltaTime,
                moveInput = move,
                jumpPressed = jump,
                interactionPressed = interaction
            });
        }
        else
        {
            InputRecord lastRecord = inputLog[^1];
            if (lastRecord.interactionPressed == interaction
                && Mathf.Approximately(lastRecord.moveInput, move)
                && lastRecord.jumpPressed == jump)
            {
                inputLog[^1].time += deltaTime;
            }
            else
            {
                inputLog.Add(new InputRecord
                {
                    time = deltaTime,
                    moveInput = move,
                    jumpPressed = jump,
                    interactionPressed = interaction
                });
            }
        }
    }
}
