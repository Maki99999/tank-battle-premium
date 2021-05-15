using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LevelSelectButton : MonoBehaviour
{
    public int level;
    public Text text;

    MainMenu menu;

    void Start()
    {
        menu = transform.parent.GetComponentInParent<MainMenu>();
    }

    public void SetLevel(int level)
    {
        this.level = level;
        text.text = "" + level;
    }

    public void StartLevel()
    {
        menu.StartLevel(level);
    }
}
