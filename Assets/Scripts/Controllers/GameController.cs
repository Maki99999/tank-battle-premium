using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TankBattlePremium
{
    public class GameController : MonoBehaviour
    {
        const string levelProgressKey = "LevelProgress";
        const string levelPrefix = "TBPLevel";

        public LayerMask collisionsLayerMask;

        public GameObject player;
        public Transform temp;

        public Animator fadeAnim;

        private static GameController _instance;
        public static GameController Instance { get { return _instance; } }

        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(this.gameObject);
            }
            else
            {
                _instance = this;
            }
        }

        public void NextLevel(int currentLevel)
        {
            PlayerPrefs.SetInt(levelProgressKey, Mathf.Max(currentLevel, PlayerPrefs.GetInt(levelProgressKey, int.MinValue)));
            StartCoroutine(LoadScene(levelPrefix + (currentLevel + 1).ToString("D3"), 3f));
        }

        IEnumerator LoadScene(string name, float waitTimeBefore = 0f)
        {
            yield return new WaitForSecondsRealtime(waitTimeBefore);
            fadeAnim.SetTrigger("FadeOut");
            yield return new WaitForSecondsRealtime(1f);

            if (Application.CanStreamedLevelBeLoaded(name))
                SceneManager.LoadScene(name);
            else
            {
                SceneManager.LoadScene("MainMenu");
                Debug.LogError("Scene not found: " + name);
            }
        }
    }
}
