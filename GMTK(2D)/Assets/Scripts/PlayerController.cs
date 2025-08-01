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

    private bool canJump = false;
    private bool isLand = true;
  
    public float fallMultiplier = 2.5f;
    public float lowJumpMultiplier = 3f;


    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        playerRigidbody = GetComponent<Rigidbody2D>();

        
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
        if (playerInput.jump)
        {
            if (isLand && canJump)
            {
                playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
                isLand = false;
            }
            canJump = false;
            // Animation
        }

        if (!playerInput.jump)
        {
            canJump = true;
        }

        if (playerRigidbody.velocity.y > 0 && !playerInput.jump)
        {
            playerRigidbody.velocity +=
                Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier - 1) * Time.fixedDeltaTime;
        }
        else if (playerRigidbody.velocity.y < 0)
        {
            playerRigidbody.velocity += Vector2.up * Physics2D.gravity.y * (fallMultiplier - 1) * Time.fixedDeltaTime;
        }

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
