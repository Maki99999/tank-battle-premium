using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class TankRotation : MonoBehaviour
    {
        public float rotSpeed = 210;

        public SmoothSound engineSound;

        private Vector3 lastPosition;
        private Vector3 lastPositionDiff;

        void Update()
        {
            if (engineSound != null)
                engineSound.desiredVolume = lastPositionDiff.sqrMagnitude * 2f;
        }

        void FixedUpdate()
        {
            lastPositionDiff = transform.position - lastPosition;

            if (lastPositionDiff.sqrMagnitude > 0.00f)
            {
                Vector3 movement = lastPositionDiff;
                if (Vector3.Angle(transform.forward, movement) > 90 || (Vector3.Angle(transform.forward, movement) == 90 && Random.value > 0.5f))
                    movement = -lastPositionDiff;

                Quaternion forwardRot = Quaternion.LookRotation(movement, Vector3.up);
                if (transform.rotation != forwardRot)
                    transform.rotation = Quaternion.RotateTowards(transform.rotation,
                            forwardRot, rotSpeed * Time.fixedDeltaTime);
            }

            lastPosition = transform.position;
        }
    }
}
