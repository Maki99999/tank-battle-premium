using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

    public class EscapeMenuManager : MonoBehaviour
    {
        public AudioMixer audioMixer;
        public GameObject MainMenu;
        public GameObject SettingsMenu;
        public Animator animator;

        [Space(10)]
        public MeshRenderer screenMesh;
        public Camera gameCamera;

        [Space(10)]
        public Slider mainVolSlider;
        public Slider fxVolSlider;
        public Slider musicVolSlider;
        public Dropdown presetDropdown;
        public Dropdown resDropdown;
        public Text resText;
        public Toggle fullscreenToggle;
        public Toggle vSyncToggle;
        public Dropdown pcResDropdown;

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
            PauseManager.Unpause();
            animator.SetBool("EscIn", false);
            animator.SetBool("SettingsIn", false);
            inMenu = false;
        }

        public void OpenMenu()
        {
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

        public void CloseGame()
        {
            Application.Quit();
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
            float mainVol = PlayerPrefs.GetFloat("mainVol", 0f);
            audioMixer.SetFloat("mainVol", mainVol);
            mainVolSlider.value = mainVol;

            float fxVol = PlayerPrefs.GetFloat("fxVol", 0f);
            audioMixer.SetFloat("metaFxVol", fxVol);
            audioMixer.SetFloat("gameFxVol", fxVol);
            audioMixer.SetFloat("uiVol", fxVol);
            fxVolSlider.value = fxVol;

            float musicVol = PlayerPrefs.GetFloat("musicVol", 0f);
            audioMixer.SetFloat("metaMusicVol", musicVol);
            audioMixer.SetFloat("gameMusicVol", musicVol);
            musicVolSlider.value = musicVol;


            int prefQualityLevel = PlayerPrefs.GetInt("QualityLevel", 0);
            QualitySettings.SetQualityLevel(prefQualityLevel);
            presetDropdown.value = prefQualityLevel;

            bool fullscreen = PlayerPrefs.GetInt("fullscreenOn", Screen.fullScreenMode == FullScreenMode.FullScreenWindow ? 1 : 0) != 0;
            fullscreenToggle.isOn = fullscreen;

            int resW = PlayerPrefs.GetInt("resW", -1);
            int resH = PlayerPrefs.GetInt("resH", -1);
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

            int vSyncCount = PlayerPrefs.GetInt("vSyncCount", QualitySettings.vSyncCount);
            QualitySettings.vSyncCount = vSyncCount;
            vSyncToggle.isOn = vSyncCount >= 0;

            int pcRes = PlayerPrefs.GetInt("pcRes", 1);
            pcResDropdown.value = pcRes;
            SetPcRes(pcRes, false);
        }

        public void SetMainVol(float vol)
        {
            audioMixer.SetFloat("mainVol", vol);
            PlayerPrefs.SetFloat("mainVol", vol);
        }

        public void SetFxVol(float vol)
        {
            audioMixer.SetFloat("metaFxVol", vol);
            audioMixer.SetFloat("gameFxVol", vol);
            audioMixer.SetFloat("uiVol", vol);
            PlayerPrefs.SetFloat("fxVol", vol);
        }

        public void SetMusicVol(float vol)
        {
            audioMixer.SetFloat("metaMusicVol", vol);
            audioMixer.SetFloat("gameMusicVol", vol);
            PlayerPrefs.SetFloat("musicVol", vol);
        }

        public void SetGraphicsPreset(int val)
        {
            QualitySettings.SetQualityLevel(val);
            PlayerPrefs.SetInt("QualityLevel", val);
        }

        public void SetResolution(int val)
        {
            Screen.SetResolution(resolutions[val].width, resolutions[val].height, Screen.fullScreenMode);

            PlayerPrefs.SetInt("resW", resolutions[val].width);
            PlayerPrefs.SetInt("resH", resolutions[val].height);
        }

        public void SetFullScreen(bool val)
        {
            Screen.fullScreenMode = val ? FullScreenMode.FullScreenWindow : FullScreenMode.Windowed;
            PlayerPrefs.SetInt("fullscreenOn", val ? 1 : 0);
        }

        public void SetVSync(bool val)
        {
            QualitySettings.vSyncCount = val ? 1 : 0;
            PlayerPrefs.SetInt("vSyncCount", val ? 1 : 0);
        }

        public void SetPcRes(int step)
        {
            SetPcRes(step, true);
        }

        private void SetPcRes(int step, bool withSave = true)
        {
            int w;
            int h;
            float scale;

            switch (step)
            {
                case 0:
                    w = 854;
                    h = 480;
                    scale = 1.5f;
                    break;
                case 1:
                    goto default;
                case 2:
                    w = 1920;
                    h = 1080;
                    scale = 0.667f;
                    break;
                case 3:
                    w = 2560;
                    h = 1440;
                    scale = 0.5f;
                    break;
                case 4:
                    w = 3840;
                    h = 2160;
                    scale = 0.333f;
                    break;
                default:
                    w = 1280;
                    h = 720;
                    scale = 1f;
                    break;
            }

            if (gameCamera.targetTexture != null)
            {
                gameCamera.targetTexture.Release();
            }

            RenderTexture newText = new RenderTexture(w, h, 24);

            gameCamera.targetTexture = newText;
            screenMesh.material.SetTexture("_MainTex", newText);

            if (withSave)
                PlayerPrefs.SetInt("pcRes", step);
        }
    }