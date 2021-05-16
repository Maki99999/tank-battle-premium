using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KillZone : MonoBehaviour
{
    void OnCollisionEnter(Collision other)
    {
        Destroy(other.gameObject);
    }

    void OnTriggerEnter(Collider other)
    {
        Destroy(other.gameObject);
    }
}