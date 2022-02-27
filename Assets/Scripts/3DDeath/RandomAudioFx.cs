using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomAudioFx : MonoBehaviour
{
    public AudioSource source;
    public AudioClip[] clips;
    public Vector2 timeRange;

    void Start()
    {
        StartCoroutine(AudioFx());
    }

    IEnumerator AudioFx()
    {
        yield return new WaitForSeconds(Random.Range(timeRange.x, timeRange.y));
        while (enabled)
        {
            if (source.isPlaying)
                continue;
            int newClip = Random.Range(0, clips.Length);
            if (clips[newClip] == source.clip)
                source.clip = clips[(newClip + 1) % clips.Length];
            else
                source.clip = clips[newClip];
            source.panStereo = Random.Range(-1f, 1f);
            source.Play();
            yield return new WaitForSeconds(Random.Range(timeRange.x, timeRange.y));
        }
    }
}
