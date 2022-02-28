using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TankBattlePremium
{
    public class DeathController : MonoBehaviour
    {
        private PlayerController playerController;
        public static bool isInLight = true;
        public static bool isActive = false;
        public static int itemsNeededCount;
        public static List<int> itemsPlaced;    //-1: wrong; 0: completely ignore; 1+: sequence
        private bool isDead = false;
        public bool startActivated = false;

        public AudioSource deathIsNearSfx;
        private float deathIsNearSfxVolume = 0f;

        public MonoBehaviour deathVolume;
        public Animator deathAnim;

        private Vector3 xomPosition;
        public Transform xom;

        public float darknessTime = 5f;
        private float timerStart = -1f;
        private bool timerActive = false;

        private void Awake()
        {
            isInLight = true;
            isActive = startActivated;
            itemsNeededCount = 0;
            itemsPlaced = new List<int>();
        }

        private void Start()
        {
            playerController = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
        }

        private void Update()
        {
            deathIsNearSfx.volume = Mathf.Lerp(deathIsNearSfx.volume, deathIsNearSfxVolume, 0.1f);

            if (!isActive || isDead || playerController.IsFrozen())
                return;

            if (!isInLight)
            {
                if (!timerActive)
                {
                    timerActive = true;
                    timerStart = Time.time;
                    xomPosition = playerController.transform.position + Random.onUnitSphere * 20f;
                    xomPosition = new Vector3(xomPosition.x, xomPosition.y * Mathf.Sign(xomPosition.y), xomPosition.z);
                }
                else if (timerActive && Time.time > timerStart + darknessTime)
                {
                    Death();
                }
                deathIsNearSfxVolume = (Time.time - timerStart) / darknessTime;
                Debug.Log((Time.time - timerStart) / darknessTime);
                xom.position = Vector3.Lerp(xomPosition, playerController.transform.position, (Time.time - timerStart) / darknessTime);
            }
            else
            {
                timerActive = false;
                deathIsNearSfxVolume = 0f;
                xom.position = Vector3.Lerp(xom.position, playerController.transform.position - 10f * Vector3.up, Time.deltaTime);
            }
        }

        public void Death()
        {
            StartCoroutine(DeathAnim());
        }

        public void SlowDeath()
        {
            StartCoroutine(SlowDeathAnim());
        }

        private IEnumerator SlowDeathAnim()
        {
            yield return new WaitForSeconds(10f);
            yield return DeathAnim();
        }

        private IEnumerator DeathAnim()
        {
            isDead = true;
            deathIsNearSfxVolume = 0f;
            deathVolume.enabled = true;
            deathAnim.SetTrigger("Death");
            yield return new WaitForSeconds(2f);
            SceneManager.LoadScene("3DDeath");
        }
    }
}