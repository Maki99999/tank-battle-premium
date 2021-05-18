using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugCam : MonoBehaviour
{
    public Camera debugCam;
    public Camera origCam;
    public FreeCam freeCam;
    bool debugCamActive = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.T))
            ToggleCam();
    }

    void ToggleCam()
    {
        debugCamActive = !debugCamActive;

        if (debugCamActive)
        {
            debugCam.enabled = true;
            freeCam.enabled = true;
            origCam.enabled = false;
        }
        else
        {
            debugCam.enabled = false;
            freeCam.enabled = false;
            origCam.enabled = true;
        }
    }
}
