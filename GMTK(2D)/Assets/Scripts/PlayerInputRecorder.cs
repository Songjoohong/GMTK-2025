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
        float move = playerInput.move;
        bool jump = playerInput.jump;
        bool interaction = playerInput.interaction;


        if (inputLog.Count == 0)
        {
            inputLog.Add(new InputRecord
            {
                time = deltaTime,
                input = playerInput
            });
        }
        else
        {
            InputRecord lastRecord = inputLog[^1];
            if (lastRecord.input.interaction == interaction
                && Mathf.Approximately(lastRecord.input.move, move)
                && lastRecord.input.jump == jump)
            {
                inputLog[^1].time += deltaTime;
            }
            else
            {
                inputLog.Add(new InputRecord
                {
                    time = deltaTime,
                    input = playerInput
                });
            }
        }
    }
}
