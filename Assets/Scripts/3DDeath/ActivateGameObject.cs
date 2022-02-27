using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class ActivateGameObject : MonoBehaviour
    {
        public GameObject activateObject;

        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                activateObject.SetActive(true);
                gameObject.SetActive(false);
            }
        }
    }
}