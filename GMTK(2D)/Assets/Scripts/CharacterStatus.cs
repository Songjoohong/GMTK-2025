using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class CharacterStatus : MonoBehaviour
{
    public enum Status
    {
        Egg,
        Chick,
        Chicken
    }

    public Status currentStatus;

    public void ChangeStatus(Status status)
    {
        this.currentStatus = status;
    }
}
