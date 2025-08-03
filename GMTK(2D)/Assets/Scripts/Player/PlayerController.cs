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

    // 애니메이션 이벤트에서 호출할 함수 (public이어야 함)
    public void PlayStepSound()
    {
        // SoundManager의 인스턴스를 통해 발걸음 소리 재생
        SoundManager.Instance.PlayRandomWalkStep();
        Debug.Log("발걸음 소리 재생!");
    }

    // 점프 소리를 재생하고 싶다면
    public void PlayJumpSound()
    {
        SoundManager.Instance.PlayRandomJump();
        Debug.Log("점프 소리 재생!");
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        Debug.Log($"충돌 감지됨: {gameObject.name} ({gameObject.layer}) <-> {collision.gameObject.name} ({collision.gameObject.layer})");
    }
}

