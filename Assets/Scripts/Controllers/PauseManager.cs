using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PauseManager : MonoBehaviour
{
    private static BooleanWrapper _paused = new BooleanWrapper(false);
    public static BooleanWrapper isPaused() { return _paused; }

    public static bool Paused { get { return _paused.Value; } }

    //List<Pausing> pausingObjects;

    void Start()
    {
        //pausingObjects = new List<Pausing>();
    }

    public static void Pause()
    {
        _paused.Value = true;
        Time.timeScale = 0;
    }

    public static void Unpause()
    {
        Time.timeScale = 1;
        _paused.Value = false;
    }
}