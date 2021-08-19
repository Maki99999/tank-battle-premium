using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

namespace TankBattlePremium
{
    public class EscapeMenuManager : MonoBehaviour
    {
        private const string strVolMaster = "volMaster";
        private const string strVolSFX = "volSfx";
        private const string strVolBGM = "volBgm";
        private const string strQuality = "QualityLevel";
        private const string strVSync = "vSyncCount";
        private const string strFullscreen = "fullscreenOn";
        private const string strResW = "resW";
        private const string strResH = "resH";

        public AudioMixer audioMixer;
        public GameObject MainMenu;
        public GameObject SettingsMenu;
        public Animator animator;

        [Space(10)]
        public RawImage blurImage;
        public Camera blurCamera;
        public int blurResWidth = 256;

        [Space(10)]
        public Slider mainVolSlider;
        public Slider sfxVolSlider;
        public Slider musicVolSlider;
        public Dropdown presetDropdown;
        public Dropdown resDropdown;
        public Text resText;
        public Toggle fullscreenToggle;
        public Toggle vSyncToggle;

        [Space(10)]
        public bool asSubMenu = false;

        bool inMenu = false;
        bool inSettings = false;

        bool pressedLastFrame = false;

        Resolution[] resolutions;

        void Start()
        {
            InitDropdowns();
            SetPrefValues();
        }

        void Update()
        {
            if (asSubMenu)
                return;

            if (Input.GetKey(KeyCode.Escape) && !pressedLastFrame)
            {
                if (inMenu)
                {
                    if (inSettings)
                        CloseSettings();
                    else
                    {
                        CloseMenu();
                    }
                }
                else
                {
                    OpenMenu();
                }
            }
            pressedLastFrame = Input.GetKey(KeyCode.Escape);
        }

        public void CloseMenu()
        {
            blurCamera.enabled = false;

            PauseManager.Unpause();
            animator.SetBool("EscIn", false);
            animator.SetBool("SettingsIn", false);
            inMenu = false;
        }

        public void OpenMenu()
        {
            blurCamera.enabled = true;
            UpdateBlurTexture();

            PauseManager.Pause();
            animator.SetBool("SettingsIn", false);
            animator.SetBool("EscIn", true);
            inMenu = true;
        }

        public void OpenSettings()
        {
            inSettings = true;
            animator.SetBool("SettingsIn", true);
        }

        public void CloseSettings()
        {
            inSettings = false;
            animator.SetBool("SettingsIn", false);
        }

        public void ToMainMenu()
        {
            StartCoroutine(LoadScene("MainMenu"));
        }

        IEnumerator LoadScene(string name)
        {
            animator.SetTrigger("FadeOut");
            yield return new WaitForSecondsRealtime(1f);
            SceneManager.LoadScene(name);
        }

        void InitDropdowns()
        {
            presetDropdown.AddOptions(new List<string>(QualitySettings.names));

            resolutions = Screen.resolutions;
            foreach (Resolution resolution in resolutions)
            {
                resDropdown.AddOptions(new List<string>() { resolution.width + " x " + resolution.height });
            }
        }

        void SetPrefValues()
        {
            float mainVol = PlayerPrefs.GetFloat(strVolMaster, 0f);
            audioMixer.SetFloat(strVolMaster, mainVol);
            mainVolSlider.value = mainVol;

            float fxVol = PlayerPrefs.GetFloat(strVolSFX, 0f);
            audioMixer.SetFloat(strVolSFX, fxVol);
            sfxVolSlider.value = fxVol;

            float musicVol = PlayerPrefs.GetFloat(strVolBGM, 0f);
            audioMixer.SetFloat(strVolBGM, musicVol);
            musicVolSlider.value = musicVol;

            int prefQualityLevel = PlayerPrefs.GetInt(strQuality, 0);
            QualitySettings.SetQualityLevel(prefQualityLevel);
            presetDropdown.value = prefQualityLevel;

            bool fullscreen = PlayerPrefs.GetInt(strFullscreen, Screen.fullScreenMode == FullScreenMode.FullScreenWindow ? 1 : 0) != 0;
            fullscreenToggle.isOn = fullscreen;

            int resW = PlayerPrefs.GetInt(strResW, -1);
            int resH = PlayerPrefs.GetInt(strResH, -1);
            int selectedRes = -1;
            for (int i = 0; i < resolutions.Length; i++)
            {
                if (resolutions[i].width == resW && resolutions[i].height == resH)
                {
                    selectedRes = i;
                    break;
                }
            }
            if (selectedRes == -1)
            {
                Screen.fullScreenMode = fullscreen ? FullScreenMode.FullScreenWindow : FullScreenMode.Windowed;
                resText.text = "???";
            }
            else
            {
                Screen.SetResolution(resolutions[selectedRes].width, resolutions[selectedRes].height, fullscreen ? FullScreenMode.FullScreenWindow : FullScreenMode.Windowed);
                resDropdown.value = selectedRes;
            }

            int vSyncCount = PlayerPrefs.GetInt(strVSync, QualitySettings.vSyncCount);
            QualitySettings.vSyncCount = vSyncCount;
            vSyncToggle.isOn = vSyncCount >= 0;
        }

        public void SetMainVol(float vol)
        {
            audioMixer.SetFloat(strVolMaster, vol);
            PlayerPrefs.SetFloat(strVolMaster, vol);
        }

        public void SetFxVol(float vol)
        {
            audioMixer.SetFloat(strVolSFX, vol);
            PlayerPrefs.SetFloat(strVolSFX, vol);
        }

        public void SetMusicVol(float vol)
        {
            audioMixer.SetFloat(strVolBGM, vol);
            PlayerPrefs.SetFloat(strVolBGM, vol);
        }

        public void SetGraphicsPreset(int val)
        {
            QualitySettings.SetQualityLevel(val);
            PlayerPrefs.SetInt(strQuality, val);
        }

        public void SetResolution(int val)
        {
            Screen.SetResolution(resolutions[val].width, resolutions[val].height, Screen.fullScreenMode);

            PlayerPrefs.SetInt(strResW, resolutions[val].width);
            PlayerPrefs.SetInt(strResH, resolutions[val].height);
        }

        public void SetFullScreen(bool val)
        {
            Screen.fullScreenMode = val ? FullScreenMode.FullScreenWindow : FullScreenMode.Windowed;
            PlayerPrefs.SetInt(strFullscreen, val ? 1 : 0);
        }

        public void SetVSync(bool val)
        {
            QualitySettings.vSyncCount = val ? 1 : 0;
            PlayerPrefs.SetInt(strVSync, val ? 1 : 0);
        }

        private void UpdateBlurTexture()
        {
            int w = Screen.width;
            int h = Screen.height;

            if (blurCamera.targetTexture != null)
            {
                blurCamera.targetTexture.Release();
            }

            RenderTexture newTexture = new RenderTexture(blurResWidth, Mathf.RoundToInt((float)blurResWidth * ((float)h / (float)w)), 24);
            newTexture.antiAliasing = 8;

            blurCamera.targetTexture = newTexture;
            blurImage.texture = newTexture;
        }

        public void RestartLevel()
        {
            StartCoroutine(LoadScene(SceneManager.GetActiveScene().name));
        }
    }
}
