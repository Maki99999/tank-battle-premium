using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FixedGlobalOffset : MonoBehaviour
{
    private Vector3 offset;

    void Start()
    {
        offset = transform.localPosition;
    }

    void Update()
    {
        if (transform.parent != null)
            transform.position = transform.parent.position + offset;
    }
}
