using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class CenterTextController : MonoBehaviour
{
    private TextMeshProUGUI text;
    private float elapsedTime = 0;
    private bool isPlaying = false;
    void Start()
    {
        text = GetComponent<TextMeshProUGUI>();
        ShowText(1);
    }

    // Update is called once per frame
    void Update()
    {
        if (isPlaying)
        {
            elapsedTime += Time.deltaTime;
            if (elapsedTime >= 1f)
            {
                text.enabled = false;
                isPlaying = false;
                elapsedTime = 0f;
            }
        }
    }

    public void ShowText(int count)
    {
        text.enabled = true;
        text.text = "Run Chicken " + count + " Run";
        isPlaying = true;
    }


}
