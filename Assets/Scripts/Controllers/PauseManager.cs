using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class PauseManager : MonoBehaviour
    {
        private static BooleanWrapper _paused = new BooleanWrapper(false);
        public static BooleanWrapper isPaused() { return _paused; }

        public static bool Paused { get { return _paused.Value; } }

        private static int pauseSem = 1;

        public static void Pause()
        {
            if (--pauseSem == 0)
            {
                _paused.Value = true;
                Time.timeScale = 0;
            }
        }

        public static void Unpause()
        {
            if (pauseSem++ == 0)
            {
                Time.timeScale = 1;
                _paused.Value = false;
            }
        }

        public static void ResetPause()
        {
            Time.timeScale = 1;
            _paused.Value = false;
            pauseSem = 1;
        }
    }
}
