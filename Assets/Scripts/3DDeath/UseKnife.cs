using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class UseKnife : MonoBehaviour, Useable
    {
        public GameObject ui;
        public UnityEngine.UI.Button ratBtn;
        public UnityEngine.UI.Button handBtn;
        public UnityEngine.UI.Button kysBtn;
        public UnityEngine.UI.Button backBtn;
        public UnityEngine.EventSystems.EventSystem eventSystem;
        public Animator handAnim;
        public Transform knife;
        public Transform ritualLookPos;
        public GameObject blackCanvas;
        public GameObject blood;

        private bool uiOpen = false;

        private PlayerController player;
        private DeathController deathController;

        private void Start()
        {
            player = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
            deathController = GameObject.FindWithTag("GameController").GetComponent<DeathController>();
        }

        private void OnEnable()
        {
            ratBtn.onClick.AddListener(UseOnRat);
            handBtn.onClick.AddListener(UseOnHand);
            kysBtn.onClick.AddListener(Kys);
            backBtn.onClick.AddListener(Back);
        }

        private void Update()
        {
            if (uiOpen)
            {
                if (eventSystem.currentSelectedGameObject == null)
                    eventSystem.SetSelectedGameObject(backBtn.gameObject);
                if (Input.GetKeyDown(KeyCode.E))
                    eventSystem.currentSelectedGameObject.GetComponent<UnityEngine.UI.Button>().onClick.Invoke();
            }
        }

        public string LookingAt()
        {
            return "Use Knife on ...";
        }

        public void Use()
        {
            if (!uiOpen)
            {
                player.SetFrozen(true);
                ui.SetActive(true);
                backBtn.Select();

                if (player.HasItem("Rat"))
                    ratBtn.gameObject.SetActive(true);
                else
                    ratBtn.gameObject.SetActive(false);
                uiOpen = true;
            }
        }

        public void Back()
        {
            eventSystem.SetSelectedGameObject(null);
            ui.SetActive(false);
            player.SetFrozen(false);
            uiOpen = false;
        }

        public void UseOnRat()
        {
            StartCoroutine(UseOnAnim("rat"));
        }

        public void UseOnHand()
        {
            StartCoroutine(UseOnAnim("hand"));
        }

        private IEnumerator UseOnAnim(string animName)
        {
            ui.SetActive(false);
            StartCoroutine(SmoothPickup(1f));
            yield return player.LookAt(ritualLookPos.position, 2f);
            handAnim.SetTrigger(animName);
            yield return new WaitForSeconds(2.55f);
            blackCanvas.SetActive(true);
            yield return new WaitForSeconds(1.3f);
            blackCanvas.SetActive(false);
            player.SetFrozen(false);
            blood.SetActive(true);
            deathController.SlowDeath();
            gameObject.SetActive(false);
        }

        public void Kys()
        {
            StartCoroutine(KysAnim());
        }

        private IEnumerator KysAnim()
        {
            ui.SetActive(false);
            StartCoroutine(SmoothPickup(1f));
            yield return player.LookAt(ritualLookPos.position, 2f);
            handAnim.SetTrigger("kys");
            yield return new WaitForSeconds(3.45f);
            blackCanvas.SetActive(true);
            yield return new WaitForSeconds(0.5f);
            if (ItemsCheck())
            {
                PreventQuit.Quit();
                Debug.Log("Game Quit");
            }
            else
            {
                deathController.Death();
            }
        }

        private bool ItemsCheck()
        {
            if (DeathController.itemsNeededCount != DeathController.itemsPlaced.Count)
                return false;

            int lastNumber = 0;
            foreach (var item in DeathController.itemsPlaced)
            {
                if (lastNumber > item)
                    return false;
                lastNumber = item;
            }
            return true;
        }

        private IEnumerator SmoothPickup(float seconds = 1f)
        {
            Vector3 oldPos = knife.position;
            Quaternion oldRot = knife.rotation;

            float rate = 1f / seconds;
            float fSmooth;
            for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
            {
                fSmooth = Mathf.SmoothStep(0f, 1f, f);

                knife.position = Vector3.Lerp(oldPos, player.itemHoldPosition.position, fSmooth);
                knife.rotation = Quaternion.Lerp(oldRot, player.itemHoldPosition.rotation, fSmooth);

                yield return null;
            }
            knife.gameObject.SetActive(false);
        }
    }
}
