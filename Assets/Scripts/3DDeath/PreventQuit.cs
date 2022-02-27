using System.Collections;
using System;
using UnityEngine;
using System.Runtime.InteropServices;

public class PreventQuit : MonoBehaviour
{
    private IntPtr unityWindow;

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
    }

    private void Update()
    {
        if (unityWindow != GetActiveWindow())
            RefocusWindow();
    }

    static bool WantsToQuit()
    {
        return false;
    }

    [RuntimeInitializeOnLoadMethod]
    static void RunOnStart()
    {
        Application.wantsToQuit += WantsToQuit;
    }

    void OnApplicationFocus(bool hasFocus)
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