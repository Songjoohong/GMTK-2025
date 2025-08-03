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
    }

    // �ִϸ��̼� �̺�Ʈ���� ȣ���� �Լ� (public�̾�� ��)
    public void PlayStepSound()
    {
        // SoundManager�� �ν��Ͻ��� ���� �߰��� �Ҹ� ���
        SoundManager.Instance.PlayRandomWalkStep();
        Debug.Log("�߰��� �Ҹ� ���!");
    }

    // ���� �Ҹ��� ����ϰ� �ʹٸ�
    public void PlayJumpSound()
    {
        SoundManager.Instance.PlayRandomJump();
        Debug.Log("���� �Ҹ� ���!");
    }
}

