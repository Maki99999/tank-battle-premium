using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class SimplePickup : MonoBehaviour, Useable
    {
        private static PlayerController player;
        public Transform itemTransform;
        public string itemName;

        private void Start()
        {
            if (player == null)
                player = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
        }

        public string LookingAt() { return ""; }

        public void Use()
        {
            gameObject.tag = "Untagged";
            player.AddItem(itemTransform, itemName);
        }
    }
}
