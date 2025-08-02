using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class CharacterController : MonoBehaviour
{
    private Rigidbody2D playerRigidbody;
    private CharacterStatus characterStatus;

    private GameObject[] children = new GameObject[3];
    private Animation[] childrenAnimation = new Animation[3];
    private List<string> animationNameList = new List<string>
    {
        "Chick_Idle",
        "Chick_Idle",
        "Chick_Idle",
        "Chick_Run",
        "Chicken_Idle",
        "Chicken_Run"
    };
    private string currentAnimName = "";

    public float accelerationTime;
    public float decelerationTime;
    public float[] maxSpeed = new float[3];

    private float currentSpeed;
    private float velocityXSmoothing;

    public float[] jumpHeight = new float[3];
    public float[] timeToApex = new float[3];
    private float[] gravity = new float[3];
    private float[] jumpVelocity = new float[3];

    private bool canJump;
    private bool isLand = true;

    public float[] fallMultiplier = new float[3];
    public float[] lowJumpMultiplier = new float[3];

    void Awake()
    {
        characterStatus = GetComponent<CharacterStatus>();
        playerRigidbody = GetComponent<Rigidbody2D>();
    }
    void Start()
    {
        for (int i = 0; i < 3; i++)
        {
            children[i] = gameObject.transform.GetChild(i).gameObject;
            childrenAnimation[i] = children[i].GetComponent<Animation>();
        }
        foreach (AnimationState state in childrenAnimation[1])
        {
            Debug.Log($"등록된 애니메이션 이름: {state.name}");
        }
        for (int i = 0; i < 3; i++)
        {
            gravity[i] = (2 * jumpHeight[i]) / Mathf.Pow(timeToApex[i], 2);
            jumpVelocity[i] = gravity[i] * timeToApex[i];
        }

        playerRigidbody.gravityScale = gravity[2] / Physics2D.gravity.magnitude;
    }

    void Update()
    {
        string nextAnimName;

        if (Mathf.Abs(playerRigidbody.velocity.x) < 0.5f)
        {
            nextAnimName = animationNameList[(int)characterStatus.currentStatus * 2];
        }
        else
        {
            nextAnimName = animationNameList[(int)characterStatus.currentStatus * 2 + 1];
        }

        if (currentAnimName != nextAnimName)
        {
            childrenAnimation[(int)characterStatus.currentStatus].CrossFade(nextAnimName, 0.1f);
            currentAnimName = nextAnimName;
        }

        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            ChangeStatus(CharacterStatus.Status.Egg);
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            ChangeStatus(CharacterStatus.Status.Chick);
        }
        else if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            ChangeStatus(CharacterStatus.Status.Chicken);
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
    }

    private void OnCollisionExit2D(Collision2D collision)
    {
        isLand = false;
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.transform.tag == "MushRoom")
        {
            if (characterStatus.currentStatus == CharacterStatus.Status.Chick)
            {
                ChangeStatus(CharacterStatus.Status.Chicken);
            }
        }
    }

    public void Move(CharacterInput input)
    {
        float targetSpeed = input.move * maxSpeed[(int)characterStatus.currentStatus];

        if (targetSpeed == 0 || targetSpeed * playerRigidbody.velocity.x < 0)
        {
            currentSpeed = Mathf.SmoothDamp(currentSpeed, targetSpeed, ref velocityXSmoothing, decelerationTime);
        }
        else
        {
            currentSpeed = Mathf.SmoothDamp(currentSpeed, targetSpeed, ref velocityXSmoothing, accelerationTime);
        }

        playerRigidbody.velocity = new Vector2(currentSpeed, playerRigidbody.velocity.y);

        if (input.move < 0)
        {
            children[(int)characterStatus.currentStatus].GetComponent<SpriteRenderer>().flipX = true;
        }
        else if(input.move > 0)
        {
            children[(int)characterStatus.currentStatus].GetComponent<SpriteRenderer>().flipX = false;
        }
    }

    public void Jump(CharacterInput input)
    {
        if (input.jump)
        {
            if (isLand && canJump)
            {
                playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity[(int)characterStatus.currentStatus]);
                isLand = false;
            }
            canJump = false;
        }

        if (!input.jump)
        {
            canJump = true;
        }

        if (playerRigidbody.velocity.y > 0 && !input.jump)
        {
            playerRigidbody.velocity +=
                Vector2.up * Physics2D.gravity.y * (lowJumpMultiplier[(int)characterStatus.currentStatus] - 1) * Time.fixedDeltaTime;
        }
        else if (playerRigidbody.velocity.y < 0)
        {
            playerRigidbody.velocity += Vector2.up * Physics2D.gravity.y * (fallMultiplier[(int)characterStatus.currentStatus] - 1) * Time.fixedDeltaTime;
        }
    }

    private void ChangeStatus(CharacterStatus.Status status)
    {
        characterStatus.ChangeStatus(status);
        playerRigidbody.gravityScale = gravity[(int)status] / Physics2D.gravity.magnitude;

        for (int i = 0; i < 3; i++)
        {
            gravity[i] = (2 * jumpHeight[i]) / Mathf.Pow(timeToApex[i], 2);
            jumpVelocity[i] = gravity[i] * timeToApex[i];
        }

        for (int i = 0; i < 3; i++)
        {
            children[i].SetActive(false);
        }

        switch (status)
        {
            case CharacterStatus.Status.Egg:
                {
                    children[0].SetActive(true);
                    break;
                }
            case CharacterStatus.Status.Chick:
                {
                    children[1].SetActive(true);
                    break;
                }
            case CharacterStatus.Status.Chicken:
                {
                    children[2].SetActive(true);
                    break;
                }
        }
    }
}
