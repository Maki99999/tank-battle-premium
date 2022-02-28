using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class AudioController : MonoBehaviour
{
    public AudioMixer audioMixer;

    private float currVol = 0f;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.KeypadPlus))
            currVol = Mathf.Clamp(currVol + 5f, -30f, 0f);
        if (Input.GetKeyDown(KeyCode.KeypadMinus))
            currVol = Mathf.Clamp(currVol - 5f, -30f, 0f);
        if (currVol < 0f)
        {
            currVol = Mathf.Clamp(currVol + 0.33f * Time.deltaTime, -30f, 0f);
        }
        audioMixer.SetFloat("volSfx", currVol);
    }
}
