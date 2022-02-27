using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace TankBattlePremium
{
    public class LoseGlitch : MonoBehaviour
    {
        public Volume glitchVolume;
        public GameObject[] gameObjectsToDisable;
        public AudioMixer audioMixer;
        public Animator cameraAnim;
        public AudioSource glitchErrNoiseLoop;
        public AudioSource loudNoise;

        private IEnumerator Start()
        {
            audioMixer.SetFloat("volBgm", -80);
            audioMixer.SetFloat("volSfx", 0);
            audioMixer.SetFloat("volMaster", 0);
            Cursor.lockState = CursorLockMode.Locked;
            Application.wantsToQuit += WantsToQuit;

            foreach (GameObject gameObject in gameObjectsToDisable)
                gameObject.SetActive(false);
            Time.timeScale = 0;
            glitchErrNoiseLoop.Play();
            cameraAnim.enabled = false;

            yield return new WaitForSecondsRealtime(3.4f);
            loudNoise.Play();
            StartCoroutine(GlitchMovementControl());
            StartCoroutine(GlitchVolumeControl());
            Cursor.visible = false;

            yield return new WaitForSecondsRealtime(2.5f);
            SceneManager.LoadScene("3DDeath");
        }

        private IEnumerator GlitchVolumeControl()
        {
            glitchVolume.enabled = true;
            glitchVolume.weight = 0;
            float rate = 1f / 5f;
            float smoothF = 0;
            for (float f = 0f; f <= 1f; f += rate * Time.unscaledDeltaTime)
            {
                smoothF = 1 - Mathf.Pow(1 - f, 3);
                glitchVolume.weight = smoothF;
                yield return null;
            }
        }

        private IEnumerator GlitchMovementControl()
        {
            cameraAnim.enabled = true;
            cameraAnim.SetTrigger("GlitchMovement");
            float rate = 1f / 2f;
            float smoothF = 0;
            for (float f = 0f; f <= 1f; f += rate * Time.unscaledDeltaTime)
            {
                smoothF = f * f * f;
                cameraAnim.SetFloat("mult", smoothF * 2.5f);
                yield return null;
            }
        }

        static bool WantsToQuit()
        {
            Debug.Log("Player prevented from quitting.");
            return false;
        }
    }
}