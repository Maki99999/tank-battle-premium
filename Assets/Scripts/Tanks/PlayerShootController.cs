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

        private Vector3 lastMousePos = Vector3.zero;
        private (float, float) lastStickPos = (0, 0);
        private bool aimingWithMouse = true;

        void Start()
        {
            nextBulletTime = Time.time + bulletCooldown;

            lastMousePos = Input.mousePosition;
            lastStickPos = (Input.GetAxis("RStickX"), Input.GetAxis("RStickY"));
        }

        void Update()
        {
            if (PauseManager.Paused)
                return;

            //Current Device
            Vector3 newMousePos = Input.mousePosition;
            (float, float) newStickPos = (Input.GetAxis("RStickX"), Input.GetAxis("RStickY"));

            if (newMousePos.Equals(lastMousePos) && !newStickPos.Equals(lastStickPos))
                aimingWithMouse = false;
            else if (!newMousePos.Equals(lastMousePos) && newStickPos.Equals(lastStickPos))
                aimingWithMouse = true;

            lastMousePos = newMousePos;
            lastStickPos = newStickPos;

            // Aim
            if (aimingWithMouse)
            {
                Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
                RaycastHit hit;
                if (Physics.Raycast(ray, out hit, Mathf.Infinity, rayhitLayer))
                {
                    Vector3 hitAdjusted = hit.point;
                    hitAdjusted = new Vector3(hitAdjusted.x, upperPart.transform.position.y, hitAdjusted.z);
                    upperPart.transform.LookAt(hitAdjusted);
                }
            }
            else
            {
                Vector3 hit = upperPart.transform.position + Vector3.right * Input.GetAxis("RStickX") + Vector3.forward * Input.GetAxis("RStickY");
                upperPart.transform.LookAt(hit);
            }

            // Shoot
            if ((Input.GetKeyDown(KeyCode.Mouse0) || Input.GetButtonDown("Fire1")) && Time.time > nextBulletTime && currBulletsOnScreen < maxBullets)
            {
                nextBulletTime = Time.time + bulletCooldown;
                Shoot();
            }
        }
    }
}
