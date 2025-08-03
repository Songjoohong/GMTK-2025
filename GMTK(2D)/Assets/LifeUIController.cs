using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LifeUIController : MonoBehaviour
{
    public GameObject chickenIconPrefab;  // 닭 아이콘 프리팹
    public Transform lifePanel; // 부모 오브젝트

    private List<GameObject> iconList = new List<GameObject>();

    public int maxLife = 20;
    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < maxLife; i++)
        {
            GameObject icon = Instantiate(chickenIconPrefab, lifePanel);
            iconList.Add(icon);
        }
        UpdateLifeUI();
    }

    // Update is called once per frame
    void Update()
    {
        UpdateLifeUI();
    }

    public void UpdateLifeUI()
    {
        for (int i = 0; i < iconList.Count; i++)
        {
            iconList[i].SetActive(i < GameManager.Instance.life);
        }
    }
}
