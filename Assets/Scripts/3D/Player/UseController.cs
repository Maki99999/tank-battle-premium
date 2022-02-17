using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class UseController : MonoBehaviour
    {
        public float range = 2.5f;
        public LayerMask mask;

        bool lastPress = false;

        void LateUpdate()
        {
            //Get Input
            bool useKey = Input.GetKeyDown(KeyCode.E);

            //Get useable GameObject and maybe use it
            RaycastHit hit;
            if (Physics.Raycast(transform.position, transform.forward, out hit, range, mask))
            {
                GameObject hitObject = hit.collider.gameObject;
                if (hitObject.CompareTag("Useable"))
                {
                    Useable useable = hitObject.GetComponent<Useable>();

                    if (useable == null)
                    {
                        Debug.LogError("Can't find 'Useable' script.");
                    }
                    else
                    {
                        useable.LookingAt();

                        if (useKey && !lastPress)
                            useable.Use();
                    }
                }
            }
            lastPress = useKey;
        }
    }

    public interface Useable
    {
        public abstract void LookingAt();
        public abstract void Use();
    }
}