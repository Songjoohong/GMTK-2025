using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DogController : MonoBehaviour
{
    private Rigidbody2D playerRigidbody;

    private GameObject child;
    private Animation childAnimation;
    private List<string> animationNameList = new List<string>
    {
        "Dog_Idle",
        "Dog_Run",
    };

    private string currentAnimName = "";

    public float accelerationTime;
    public float decelerationTime;
    public float maxSpeed;

    private float currentSpeed;
    private float velocityXSmoothing;

    public float jumpHeight;
    public float timeToApex;
    private float gravity;
    private float jumpVelocity;

    private bool isLand = true;

    private Vector2 currentPos;
    private Vector2 previousPos;

    void Awake()
    {
        playerRigidbody = GetComponent<Rigidbody2D>();
    }
    void Start()
    {

        child = gameObject.transform.GetChild(0).gameObject;
        childAnimation = child.GetComponent<Animation>();

        gravity = (2 * jumpHeight) / Mathf.Pow(timeToApex, 2);
        jumpVelocity = gravity * timeToApex;

        playerRigidbody.gravityScale = gravity / Physics2D.gravity.magnitude;
    }

    void FixedUpdate()
    {
        previousPos = currentPos;
        currentPos = transform.position;

        if ((currentPos - previousPos).x < 0)
        {
            child.GetComponent<SpriteRenderer>().flipX = false;
        }
        else if ((currentPos - previousPos).x > 0)
        {
            child.GetComponent<SpriteRenderer>().flipX = true;
        }
        //string nextAnimName;
        //Debug.Log(currentAnimName);
        //if (Mathf.Abs(currentPos.x - previousPos.x) < 0.5f)
        //{
        //    nextAnimName = animationNameList[0];
        //}
        //else
        //{
        //    nextAnimName = animationNameList[1];
        //}

        //if (currentAnimName != nextAnimName)  
        //{
        //    childAnimation.Play(nextAnimName);
        //    currentAnimName = nextAnimName;
        //}
        childAnimation.Play("Dog_Run");
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
            if (isLand)
            {
                playerRigidbody.velocity = new Vector2(playerRigidbody.velocity.x, jumpVelocity);
                isLand = false;
            }
        }
    }
}
