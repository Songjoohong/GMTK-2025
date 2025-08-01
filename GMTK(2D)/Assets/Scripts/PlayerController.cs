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

    public float jumpForce;
    private bool isLand = true;


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
        if (playerInput.jump && isLand)
        {
            //playerRigidbody.AddForce(Vector2.up * jumpForce, ForceMode2D.Impulse);
            playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
            isLand = false;
            // Animation
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

    private float AccelerationGraph(float time)
    {
        return maxSpeed / (accelerationTime * accelerationTime) * time * time;
    }

    private float DecelerationGraph(float time, float startSpeed)
    {
        float result = maxSpeed / (accelerationTime * accelerationTime) * (time - (decelerationTime - ((float)Math.Sqrt(decelerationTime * startSpeed / maxSpeed) + decelerationTime))) * (time - (decelerationTime - ((float)Math.Sqrt(decelerationTime * startSpeed / maxSpeed) + decelerationTime)));

        return Mathf.Abs(result) < 0.5f ? 0 : result;
    }
}
