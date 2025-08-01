using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    private Rigidbody2D playerRigidbody;
    public Collider2D footCollider;
    public float moveSpeed;
    public float maxSpeed;
    public float jumpForce;
    private bool isLand = true;

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        playerRigidbody = GetComponent<Rigidbody2D>();
    }

    private void FixedUpdate()
    {
        Move();
        Jump();
    }

    private void Move()
    {
        playerRigidbody.AddForce(Vector2.right * playerInput.move * moveSpeed, ForceMode2D.Force);

        if (playerRigidbody.velocity.x > maxSpeed)
        {
            playerRigidbody.velocity = new Vector2(maxSpeed, playerRigidbody.velocity.y);
        }
        else if (playerRigidbody.velocity.x < -maxSpeed)
        {
            playerRigidbody.velocity = new Vector2(-maxSpeed, playerRigidbody.velocity.y);
        }
        if (playerInput.move == 0)
        {
            playerRigidbody.velocity = new Vector2(0, playerRigidbody.velocity.y);
            // Animation
        }
        else if (playerInput.move < 0)
        {
            if (playerRigidbody.velocity.x > 0)
            {
                playerRigidbody.velocity = new Vector2(0, playerRigidbody.velocity.y);
            }
            // Animation
            // Sprite flip
        }
        else if (playerInput.move > 0)
        {
            if (playerRigidbody.velocity.x < 0)
            {
                playerRigidbody.velocity = new Vector2(0, playerRigidbody.velocity.y);
            }
            // Animation
            // Sprite flip
        }
    }

    private void Jump()
    {
        if (playerInput.jump && isLand)
        {
            playerRigidbody.AddForce(Vector2.up * jumpForce, ForceMode2D.Impulse);
            isLand = false;
            // Animation
        }

        if (playerRigidbody.velocity.y > 0)
        {
            // Animation
            footCollider.enabled = false;
        }
        else if (playerRigidbody.velocity.y < 0)
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
