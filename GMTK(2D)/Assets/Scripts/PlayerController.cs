using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    private Rigidbody2D playerRigidbody;
    public Collider2D footCollider;

    public float accelerationTime;
    public float decelerationTime;
    public float maxSpeed;

    private float currentSpeed;
    private float velocityXSmoothing;

    public float jumpHeight = 6f;
    public float timeToApex = 0.5f;
    private float gravity;
    private float jumpVelocity;
    private bool jumpRequested = false;

    public float jumpForce;
    private bool isLand = true;
    private bool jumpHeld = false; //  → 눌려 있는 상태 추적
    private float jumpTimeCounter;
    public float maxJumpTime = 0.25f; // 최대 유지 시간

    public float fallMultiplier = 2.5f;
    public float lowJumpMultiplier = 3f;


    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        playerRigidbody = GetComponent<Rigidbody2D>();

        
    }

    void Update()
    {
        if (playerInput.jumpPressed && isLand)
        {
            jumpRequested = true;
        }
    }

    private void FixedUpdate()
    {
        gravity = (2 * jumpHeight) / Mathf.Pow(timeToApex, 2);
        jumpVelocity = gravity * timeToApex;

        Physics2D.gravity = new Vector2(0, -gravity);

        Move();
        Jump();
    }

    private void Move()
    {
        float targetSpeed = playerInput.move * maxSpeed;

        if (targetSpeed == 0 || targetSpeed * playerRigidbody.velocity.x < 0)
        {
            currentSpeed = Mathf.SmoothDamp(currentSpeed, targetSpeed, ref velocityXSmoothing, decelerationTime);
        }
        else
        {
            currentSpeed = Mathf.SmoothDamp(currentSpeed, targetSpeed, ref velocityXSmoothing, accelerationTime);
        }

        playerRigidbody.velocity = new Vector2(currentSpeed, playerRigidbody.velocity.y);
    }

    private void Jump()
    {
        if (jumpRequested)
        {
            playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
            isLand = false;
            jumpHeld = true;
            jumpTimeCounter = maxJumpTime;
            jumpRequested = false; // 한 번 쓰고 꺼줘야 함
        }

        if (playerInput.jumpPressed && isLand)
        {
            playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
            isLand = false;
            jumpHeld = true;
            jumpTimeCounter = maxJumpTime;
            // Animation
        }
        // 버튼 누르고 있는 동안 상승 유지 (중력 약화)
        if (jumpHeld && playerInput.jump)
        {
            if (jumpTimeCounter > 0)
            {
                playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
                jumpTimeCounter -= Time.fixedDeltaTime;
            }
            else
            {
                jumpHeld = false;
            }
        }

        // 버튼에서 손 뗐을 때 or 점프 끝
        if (!playerInput.jump)
        {
            jumpHeld = false;
        }

        // 상승 중 버튼 떼면 빨리 낙하
        if (playerRigidbody.velocity.y > 0 && !playerInput.jump)
        {
            playerRigidbody.velocity += Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier - 1) * Time.fixedDeltaTime;
        }

        // 낙하 중 가속 낙하
        if (playerRigidbody.velocity.y < 0)
        {
            playerRigidbody.velocity += Vector2.up * Physics2D.gravity.y * (fallMultiplier - 1) * Time.fixedDeltaTime;
        }

        /*if (playerRigidbody.velocity.y > 0 && !playerInput.jump)
        {
            playerRigidbody.velocity +=
                Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier - 1) * Time.fixedDeltaTime;
        }
        else if (playerRigidbody.velocity.y < 0)
        {
            playerRigidbody.velocity += Vector2.up * Physics2D.gravity.y * (fallMultiplier - 1) * Time.fixedDeltaTime;
        }*/

    }

    private void OnCollisionStay2D(Collision2D collision)
    {
        foreach (ContactPoint2D contact in collision.contacts)
        {
            if (Vector2.Dot(contact.normal, Vector2.up) > 0.5f)
            {
                isLand = true;
            }
        }
        // Animation
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        foreach (ContactPoint2D contact in collision.contacts)
        {
            if (Vector2.Dot(contact.normal, Vector2.up) > 0.5f)
            {
                isLand = true;
            }
        }
        // Animation
    }

    private void OnCollisionExit2D(Collision2D collision)
    {
        isLand = false;
        // Animation
    }
}
