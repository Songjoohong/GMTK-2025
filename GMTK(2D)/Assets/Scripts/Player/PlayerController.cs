using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    private Rigidbody2D playerRigidbody;
    private CharacterController characterController;
    public Collider2D footCollider;

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        playerRigidbody = GetComponent<Rigidbody2D>();
        characterController = GetComponent<CharacterController>();
    }

    private void FixedUpdate()
    {
        characterController.Move(playerInput.input);
        characterController.Jump(playerInput.input);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            GameManager.Instance.PlayerDie();
            Destroy(this.gameObject);
        }
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        Debug.Log($"Ãæµ¹ °¨ÁöµÊ: {gameObject.name} ({gameObject.layer}) <-> {collision.gameObject.name} ({collision.gameObject.layer})");
    }
}
