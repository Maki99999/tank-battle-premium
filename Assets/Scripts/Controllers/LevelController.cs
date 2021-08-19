using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class LevelController : MonoBehaviour
    {
        private static LevelController _instance;
        public static LevelController Instance { get { return _instance; } }

        public int levelId;

        public GameObject winObject;
        public GameObject loseObject;

        [Space(10)]
        public float pauseAtBeginning = 2f;

        private int countTargetsToDestroy;
        private bool gameOver = false;

        void Awake()
        {
            if (_instance != null && _instance != this)
                Destroy(this.gameObject);
            else
                _instance = this;
        }

        void Start()
        {
            TargetController[] targets = GameObject.FindObjectsOfType<TargetController>();
            countTargetsToDestroy = 0;
            foreach (TargetController target in targets)
            {
                if (target.type == TargetType.LEVEL_DEFEAT)
                    countTargetsToDestroy++;
            }

            StartCoroutine(PauseAtBeginning());
        }

        IEnumerator PauseAtBeginning()
        {
            PauseManager.ResetPause();
            PauseManager.Pause();
            yield return new WaitForSecondsRealtime(pauseAtBeginning);
            PauseManager.Unpause();
        }

        public void TargetDied(TargetType type)
        {
            if (gameOver)
                return;

            switch (type)
            {
                case TargetType.LEVEL_DEFEAT:
                    if (--countTargetsToDestroy <= 0)
                        Win();
                    break;
                case TargetType.LEVEL_PROTECT:
                    Lose();
                    break;
                default:
                    break;
            }
        }

        private void GameOver()
        {
            gameOver = true;
        }

        private void Win()
        {
            GameOver();
            winObject.SetActive(true);
            GameController.Instance.NextLevel(levelId);
        }

        private void Lose()
        {
            GameOver();
            loseObject.SetActive(true);
        }
    }
}
