using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class DebugController : MonoBehaviour
{
    public AudioMixer audioMixer;

    void Start()
    {
        SetVolumeFX(-22);
        SetVolumeBGM(-22);
    }

    public void SetVolumeFX(float volume)
    {
        audioMixer.SetFloat("volFx", volume);
    }

    public void SetVolumeBGM(float volume)
    {
        audioMixer.SetFloat("volBgm", volume);
    }
}
