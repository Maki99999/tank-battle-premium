using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlobalThings : MonoBehaviour
{
    public static GlobalThings instance;

    public GameObject player;
    public Transform temp;

    void Awake()
    {
        instance = this;
    }
}
