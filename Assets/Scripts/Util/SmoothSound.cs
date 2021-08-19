using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class SmoothSound : MonoBehaviour
    {
        public AudioSource audioSource;

        public float smoothingMultiplier = 1f;
        public float desiredVolume;

        void Start()
        {
            audioSource.volume = desiredVolume;
        }

        void Update()
        {
            audioSource.volume = Mathf.Lerp(audioSource.volume, desiredVolume, Time.deltaTime * smoothingMultiplier);
        }
    }
}
