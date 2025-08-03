using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class Timer : MonoBehaviour
{
    public TextMeshProUGUI text;
    // Start is called before the first frame update
    void Start()
    {
        text = GetComponent<TextMeshProUGUI>();
    }

    // Update is called once per frame
    void Update()
    {
        int minute = (int)GameManager.Instance.timer / 60;
        int sec = (int)GameManager.Instance.timer - minute * 60;
        text.text = minute.ToString("00") + " : " + sec.ToString("00");
    } 
}
