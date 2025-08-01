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
    private Rigidbody2D rigidbody;
    public float moveSpeed = 100f;
    public float maxSpeed = 5f;
    public float jumpForce = 5f;
    private bool isLand;
    private Collider2D footCollider;
    public GameObject player;

    
    void Start()
    {
        controller = GetComponent<PlayerController>();
        rigidbody = GetComponent<Rigidbody2D>();
    }

    void FixedUpdate()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            replayStart = true;
            inputLog = player.GetComponent<PlayerInputRecorder>().inputLog;
        }

        if (replayStart)
        {
            npcElapsedTime += Time.fixedDeltaTime;

            if(currentIndex >= inputLog.Count) return;

            InputRecord input = inputLog[currentIndex];

            if (input.time >= npcElapsedTime)
            {
                Move(input.input);
                Jump(input.input);
            }
            else
            {
                npcElapsedTime = 0f;
                currentIndex++;
            }
        }
    }

    private void Move(PlayerInput input)
    {
        rigidbody.AddForce(Vector2.right * input.move * moveSpeed, ForceMode2D.Force);

        if (rigidbody.velocity.x > maxSpeed)
        {
            rigidbody.velocity = new Vector2(maxSpeed, rigidbody.velocity.y);
        }
        else if (rigidbody.velocity.x < -maxSpeed)
        {
            rigidbody.velocity = new Vector2(-maxSpeed, rigidbody.velocity.y);
        }
        if (input.move == 0)
        {
            rigidbody.velocity = new Vector2(0, rigidbody.velocity.y);
            // Animation
        }
        else if (input.move < 0)
        {
            if (rigidbody.velocity.x > 0)
            {
                rigidbody.velocity = new Vector2(0, rigidbody.velocity.y);
            }
            // Animation
            // Sprite flip
        }
        else if (input.move > 0)
        {
            if (rigidbody.velocity.x < 0)
            {
                rigidbody.velocity = new Vector2(0, rigidbody.velocity.y);
            }
            // Animation
            // Sprite flip
        }
    }

    private void Jump(PlayerInput input)
    {
        if (input.jump && isLand)
        {
            rigidbody.AddForce(Vector2.up * jumpForce, ForceMode2D.Impulse);
            isLand = false;
            // Animation
        }

        if (rigidbody.velocity.y > 0)
        {
            // Animation
            footCollider.enabled = false;
        }
        else if (rigidbody.velocity.y < 0)
        {
            // Animation
            footCollider.enabled = true;
        }
    }

    private void OnCollisionStay2D(Collision2D collision)
    {
        isLand = true;
        // Animation
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        isLand = true;
        // Animation
    }

    private void OnCollisionExit2D(Collision2D collision)
    {
        isLand = false;
        // Animation
    }
}
