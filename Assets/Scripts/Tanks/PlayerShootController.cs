using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class PlayerShootController : Shooter
    {
        public GameObject upperPart;
        public LayerMask rayhitLayer;

        public float bulletCooldown = 0.5f;
        private float nextBulletTime = -1;

        public int maxBullets;

        void Start()
        {
            nextBulletTime = Time.time + bulletCooldown;
        }

        void Update()
        {
            if (PauseManager.Paused)
                return;
            // Aim
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, Mathf.Infinity, rayhitLayer))
            {
                Vector3 hitAdjusted = hit.point;
                hitAdjusted = new Vector3(hitAdjusted.x, upperPart.transform.position.y, hitAdjusted.z);
                upperPart.transform.LookAt(hitAdjusted);
            }

            // Shoot
            if (Input.GetKeyDown(KeyCode.Mouse0) && Time.time > nextBulletTime && currBulletsOnScreen < maxBullets)
            {
                nextBulletTime = Time.time + bulletCooldown;
                Shoot();
            }
        }
    }
}
