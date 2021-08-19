using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class PlayerMovement : MonoBehaviour
    {
        public float speed = 21;
        public float rotSpeed = 210;

        public new Rigidbody rigidbody;
        public SmoothSound engineSound;

        private Vector3 nextMovement;

        void Update()
        {
            // Move
            float x = Input.GetAxisRaw("Horizontal");
            float z = Input.GetAxisRaw("Vertical");

            nextMovement = new Vector3(x, 0, z).normalized;
            engineSound.desiredVolume = nextMovement.sqrMagnitude / 3f;
            nextMovement *= speed;
        }

        void FixedUpdate()
        {
            rigidbody.velocity = nextMovement * speed;

            if (nextMovement.sqrMagnitude > 0.00f)
            {
                Vector3 movement = nextMovement;
                if (Vector3.Angle(transform.forward, movement) > 90 || (Vector3.Angle(transform.forward, movement) == 90 && Random.value > 0.5f))
                    movement = -nextMovement;

                rigidbody.MoveRotation(Quaternion.RotateTowards(transform.rotation,
                        Quaternion.LookRotation(movement, Vector3.up), rotSpeed * Time.deltaTime));
            }
        }
    }
}
