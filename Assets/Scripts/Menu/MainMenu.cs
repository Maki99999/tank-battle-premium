using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    const int levelCount = 59;
    const string levelProgressKey = "LevelProgress";
    const string levelPrefix = "TBPLevel";

    [HideInInspector] public int levelCompleted;
    public Button continueStartButton;
    public Animator anim;

    public GridLayoutGroup gridLayout;
    public Transform levelButtonParent;
    public GameObject levelButtonPrefab;

    Text continueStartButtonText;

    void Start()
    {
        continueStartButtonText = continueStartButton.GetComponentInChildren<Text>();
        levelCompleted = PlayerPrefs.GetInt(levelProgressKey, 0);
        if (levelCompleted < 1)
        {
            PlayerPrefs.SetInt(levelProgressKey, 0);
            continueStartButtonText.text = "Start";
        }

        MakeLevelButtons();
    }

    public void ContinueStart()
    {
        StartCoroutine(LoadScene(levelPrefix + (levelCompleted + 1).ToString("D3")));
    }

    public void BackToMainMenu()
    {
        StartCoroutine(LoadScene("MainMenu"));
    }

    public void OpenLevelSelector()
    {
        anim.SetBool("OpenLevelSelect", true);
    }

    public void CloseLevelSelector()
    {
        anim.SetBool("OpenLevelSelect", false);
    }

    public void StartLevel(int level)
    {
        StartCoroutine(LoadScene(levelPrefix + level.ToString("D3")));
    }

    IEnumerator LoadScene(string name)
    {
        anim.SetTrigger("FadeOut");
        yield return new WaitForSeconds(1f);
        SceneManager.LoadScene(name);
    }

    void MakeLevelButtons()
    {
        Rect rect = levelButtonParent.GetComponent<RectTransform>().rect;
        float availableWidth = rect.width - 10 * 10;

        int rows = Mathf.CeilToInt(levelCount / 10);
        float availableHeight = rect.height - rows * 10;

        gridLayout.cellSize = new Vector2(availableWidth / 10, Mathf.Clamp(availableHeight / rows, 10, 50));

        for (int i = 1; i <= levelCount; i++)
        {
            GameObject newButton = Instantiate(levelButtonPrefab, Vector3.zero, Quaternion.identity, levelButtonParent);
            newButton.transform.localRotation = Quaternion.identity;
            newButton.GetComponent<LevelSelectButton>().SetLevel(i);
            if (i > levelCompleted + 1)
            {
                newButton.GetComponent<Button>().interactable = false;
            }
            if (i == levelCount)
            {
                newButton.GetComponent<Image>().color = new Color(1f, 0.5f, 0.5f);
            }
        }
    }
}
