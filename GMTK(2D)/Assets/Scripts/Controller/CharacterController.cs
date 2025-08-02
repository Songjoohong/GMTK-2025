using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class CharacterController : MonoBehaviour
{
    private Rigidbody2D playerRigidbody;

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
        gravity = (2 * jumpHeight) / Mathf.Pow(timeToApex, 2);
        jumpVelocity = gravity * timeToApex;

        Physics2D.gravity = new Vector2(0, -gravity);

        playerRigidbody = GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Move(CharacterInput input)
    {
        float targetSpeed = input.move * maxSpeed;

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

    public void Jump(CharacterInput input)
    {
        if (input.jump)
        {
            if (isLand && canJump)
            {
                playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
                isLand = false;
            }
            canJump = false;
            // Animation
        }

        if (!input.jump)
        {
            canJump = true;
        }

        if (playerRigidbody.velocity.y > 0 && !input.jump)
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
