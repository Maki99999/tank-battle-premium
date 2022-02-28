using System.Collections;
using System;
using UnityEngine;
using System.Runtime.InteropServices;

public class PreventQuit : MonoBehaviour
{
    private static bool eventAttached = false;
    private IntPtr unityWindow;
    private static bool isAllowedToQuit = false;

    [DllImport("user32.dll")]
    static extern IntPtr GetActiveWindow();

    [DllImport("user32.dll")]
    static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

    const int ALT = 0xA4;
    const int EXTENDEDKEY = 0x1;
    const int KEYUP = 0x2;

    private void Start()
    {
        unityWindow = GetActiveWindow();

        if (!eventAttached)
        {
            eventAttached = true;
            Application.wantsToQuit += PreventQuit.WantsToQuit;
        }
    }

    private void Update()
    {
        if (unityWindow != GetActiveWindow())
            RefocusWindow();
    }

    private static bool WantsToQuit()
    {
        return isAllowedToQuit;
    }

    public static void Quit()
    {
        isAllowedToQuit = true;
        Application.wantsToQuit -= PreventQuit.WantsToQuit;
        Application.Quit();
    }

    private void OnApplicationFocus(bool hasFocus)
    {
        if (!hasFocus)
        {
            RefocusWindow();
        }
    }

    private void RefocusWindow()
    {
        // Simulate alt press
        keybd_event((byte)ALT, 0x45, EXTENDEDKEY | 0, 0);

        // Simulate alt release
        keybd_event((byte)ALT, 0x45, EXTENDEDKEY | KEYUP, 0);

        SetForegroundWindow(unityWindow);
    }
}