using System.Collections.Generic;
using UnityEngine;

public class MushroomManager : MonoBehaviour
{
    private List<GameObject> mushroomObjects = new List<GameObject>();

    void Start()
    {
        mushroomObjects.AddRange(GameObject.FindGameObjectsWithTag("MushRoom"));
    }

    public void ResetMushrooms()
    {
        foreach (var mushroom in mushroomObjects)
        {
            if (mushroom != null)
                mushroom.SetActive(true);
        }
    }
}