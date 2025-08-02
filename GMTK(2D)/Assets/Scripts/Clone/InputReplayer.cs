using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class InputReplayer : MonoBehaviour
{
    public List<InputRecord> inputLog;
    private int currentIndex = 0;
    private float npcElapsedTime = 0f;
    private bool replayStart = false;
    private PlayerController controller;
    private CharacterController characterController;


    void Start()
    {
        controller = GetComponent<PlayerController>();
        characterController = GetComponent<CharacterController>();
    }

    void FixedUpdate()
    {
        if (inputLog != null)
        {
            npcElapsedTime += Time.fixedDeltaTime;

            if (currentIndex >= inputLog.Count) return;

            InputRecord input = inputLog[currentIndex];

            if (input.time >= npcElapsedTime)
            {
                characterController.Move(input.input);
                characterController.Jump(input.input);
            }
            else
            {
                npcElapsedTime = 0f;
                currentIndex++;
            }
        }
    }

    public void Replay(Vector2 pos)
    {
        this.gameObject.transform.position = pos;
        currentIndex = 0;
    }

    public void GetInputLog(List<InputRecord> log)
    {
        inputLog = log;
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        Debug.Log($"Ãæµ¹ °¨ÁöµÊ: {gameObject.name} ({gameObject.layer}) <-> {collision.gameObject.name} ({collision.gameObject.layer})");
    }
}
