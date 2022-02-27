using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomClock : MonoBehaviour
{
    public CanvasGroup canvasGroup;
    public Transform secondsHand;
    public Vector2 timeRange;

    void Start()
    {
        StartCoroutine(ClockLoop());
    }

    IEnumerator ClockLoop()
    {
        yield return new WaitForSeconds(15f);
        while (enabled)
        {
            StartCoroutine(SpinHand(5f));
            float rate = 1f / 2f;
            for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
            {
                canvasGroup.alpha = Mathf.SmoothStep(0f, 1f, f);
                yield return null;
            }
            yield return new WaitForSeconds(1f);
            for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
            {
                canvasGroup.alpha = Mathf.SmoothStep(1f, 0f, f);
                yield return null;
            }
            canvasGroup.alpha = 0f;

            yield return new WaitForSeconds(Random.Range(timeRange.x, timeRange.y));
        }
    }

    IEnumerator SpinHand(float seconds)
    {
        secondsHand.Rotate(0f, 0f, Random.Range(0, 360f));
        float rate = 1f / seconds;
        for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
        {
            secondsHand.Rotate(0f, 0f, 33 * Time.deltaTime);
            yield return null;
        }
    }
}
