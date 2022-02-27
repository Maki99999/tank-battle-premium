using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class Light : MonoBehaviour
    {
        public UnityEngine.Light topLight;
        public UnityEngine.Light additionalLight;
        public Collider playerTrigger;
        public bool disappears;

        public void Hide()
        {
            StartCoroutine(HideAnime());
        }

        private IEnumerator HideAnime()
        {
            playerTrigger.enabled = false;

            float lightIntensity = topLight.intensity;
            float rate = 1f / 2.5f;
            float smoothF = 0;
            for (float f = 0f; f <= 1f; f += rate * Time.unscaledDeltaTime)
            {
                smoothF = Mathf.SmoothStep(0f, 1f, f);
                topLight.intensity = Mathf.Lerp(lightIntensity, 0f, smoothF);
                if (additionalLight != null)
                    additionalLight.intensity = Mathf.Lerp(lightIntensity, 0f, smoothF);
                yield return null;
            }
            topLight.enabled = false;
        }

        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                DeathController.isInLight = true;
            }
        }

        private void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                DeathController.isInLight = false;
                if (disappears)
                    Hide();
            }
        }
    }
}