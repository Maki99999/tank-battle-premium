using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TankBattlePremium
{
    public class UseController : MonoBehaviour
    {
        public float range = 2.5f;
        public LayerMask mask;
        public Text useText;

        private bool lastPress = false;

        void LateUpdate()
        {
            if (!isActiveAndEnabled)
                return;

            //Get Input
            bool useKey = Input.GetKeyDown(KeyCode.E);

            useText.text = "";
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
                        string useableText = useable.LookingAt();
                        if (useableText.Trim() == "")
                            useText.text = "[ E ]";
                        else
                            useText.text = "[ E - " + useableText + " ]";

                        if (useKey && !lastPress)
                            useable.Use();
                    }
                }
            }

            lastPress = useKey;
        }

        private void OnDisable()
        {
            if (useText != null)
                useText.text = "";
        }
    }

    public interface Useable
    {
        public abstract string LookingAt();
        public abstract void Use();
    }
}