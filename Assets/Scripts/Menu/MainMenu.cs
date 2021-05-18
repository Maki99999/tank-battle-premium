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
        Application.Quit();
    }

    public void OpenLevelSelector()
    {
        anim.SetBool("OpenLevelSelect", true);
    }

    public void CloseLevelSelector()
    {
        anim.SetBool("OpenLevelSelect", false);
    }

    public void OpenSettings()
    {
        anim.SetBool("OpenSettings", true);
    }

    public void CloseSettings()
    {
        anim.SetBool("OpenSettings", false);
    }

    public void OpenCredits()
    {
        anim.SetBool("OpenCredits", true);
    }

    public void CloseCredits()
    {
        anim.SetBool("OpenCredits", false);
    }

    public void StartLevel(int level)
    {
        StartCoroutine(LoadScene(levelPrefix + level.ToString("D3")));
    }

    IEnumerator LoadScene(string name, float waitTimeBefore = 0f)
    {
        yield return new WaitForSecondsRealtime(waitTimeBefore);
        anim.SetTrigger("FadeOut");
        yield return new WaitForSecondsRealtime(1f);

        if (Application.CanStreamedLevelBeLoaded(name))
            SceneManager.LoadScene(name);
        else
        {
            SceneManager.LoadScene("MainMenu");
            Debug.LogError("Scene not found: " + name);
        }
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
