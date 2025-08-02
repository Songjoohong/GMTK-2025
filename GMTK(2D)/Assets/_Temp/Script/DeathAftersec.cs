using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathAftersec : MonoBehaviour
{
    public float sec = 1.0f;

    // Start is called before the first frame update
    void Start()
    {
        Destroy(this.gameObject, sec);   
    }
}
