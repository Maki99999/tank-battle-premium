using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class MusicController : MonoBehaviour
    {
        private static MusicController _instance;
        public static MusicController Instance { get { return _instance; } }

        public AudioSource audioSource;

        void Awake()
        {
            DontDestroyOnLoad(gameObject);

            if (_instance != null && _instance != this)
            {
                Destroy(this.gameObject);
                return;
            }
            else
                _instance = this;

            audioSource.Play();
        }

        public void ChangeMusic(AudioClip newSong)
        {
            audioSource.clip = newSong;
            audioSource.Play();
        }
    }
}
