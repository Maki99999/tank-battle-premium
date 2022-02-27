using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class PickupPlacer : MonoBehaviour, Useable
    {
        private static PlayerController player;
        private static DeathController deathController;
        public string itemName;
        public string useDescription = "";
        public bool consumeItem = true;
        public int isNeededNumber = -1;

        private List<Material> materials = new List<Material>();
        private bool placed = false;

        public GameObject[] objectsToActivate;
        public GameObject[] objectsToDeactivate;

        private void Start()
        {
            if (player == null)
                player = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
            if (deathController == null)
                deathController = GameObject.FindWithTag("GameController").GetComponent<DeathController>();

            foreach (var item in GetComponents<Renderer>())
                materials.AddRange(item.materials);

            foreach (var item in GetComponentsInChildren<Renderer>())
                materials.AddRange(item.materials);

            foreach (Material material in materials)
                material.SetFloat("_Opacity", 0.2f);

            if (isNeededNumber > 0)
                DeathController.itemsNeededCount++;
        }

        private void Update()
        {
            if (!placed)
            {
                if (player.HasItem(itemName) && !CompareTag("Useable"))
                    gameObject.tag = "Useable";
                else if (!player.HasItem(itemName) && CompareTag("Useable"))
                    gameObject.tag = "Untagged";

                foreach (Material material in materials)
                    material.SetFloat("_Opacity", 0f);
            }
        }

        public string LookingAt()
        {
            if (player.HasItem(itemName) && !placed)
                foreach (Material material in materials)
                    material.SetFloat("_Opacity", 0.2f);

            return useDescription;
        }

        public void Use()
        {
            placed = true;

            gameObject.tag = "Untagged";
            if (consumeItem)
                player.RemoveItem(itemName);
            if (isNeededNumber != 0)
                DeathController.itemsPlaced.Add(isNeededNumber);

            foreach (Material material in materials)
                material.SetFloat("_Opacity", 1f);

            foreach (GameObject gameObject in objectsToActivate)
                gameObject.SetActive(true);
            foreach (GameObject gameObject in objectsToDeactivate)
                gameObject.SetActive(false);
            foreach (Collider collider in GetComponents<Collider>())
                collider.enabled = false;
        }
    }
}
