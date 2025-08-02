using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PlayerInputRecorder : MonoBehaviour
{
    public PlayerInput playerInput;
    public List<InputRecord> inputLog = new List<InputRecord>();
    private float deltaTime = 0f;

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
    }

    void FixedUpdate()
    {
        deltaTime = Time.fixedDeltaTime;
        float moveRecord = playerInput.input.move;
        bool jumpRecord = playerInput.input.jump;
        bool interactionRecord = playerInput.input.interaction;


        if (inputLog.Count == 0)
        {
            inputLog.Add(new InputRecord
            {
                time = deltaTime,
                input = new CharacterInput
                {
                    move = moveRecord,
                    jump = jumpRecord,
                    interaction = interactionRecord
                }
            });
        }
        else
        {
            InputRecord lastRecord = inputLog[^1];
            if (lastRecord.input.interaction == interactionRecord
                && Mathf.Approximately(lastRecord.input.move, moveRecord)
                && lastRecord.input.jump == jumpRecord)
            {
                inputLog[^1].time += deltaTime;
            }
            else
            {
                inputLog.Add(new InputRecord
                {
                    time = deltaTime,
                    input = new CharacterInput
                    {
                        move = moveRecord,
                        jump = jumpRecord,
                        interaction = interactionRecord
                    }
                });
            }
        }
    }
}
