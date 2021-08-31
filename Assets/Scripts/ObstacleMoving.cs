using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class ObstacleMoving : MonoBehaviour
    {
        public Animator animator;

        void Start()
        {
            animator.Play("Obstacle Moving", 1, Random.Range(0f, 3f));
            animator.Play("Obstacle", 0, Random.Range(0f, 3f));
        }
    }
}
