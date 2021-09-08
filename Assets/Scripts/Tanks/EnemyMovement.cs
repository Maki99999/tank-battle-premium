using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace TankBattlePremium
{
    public class EnemyMovement : MonoBehaviour
    {
        public EnemyStatic enemyStatic;
        public float speed = 21;
        public NavMeshAgent agent;
        public Vector2 wanderCooldown;
        public float wanderRange;

        private float nextWanderChangeTime = -1;

        void Start()
        {
            nextWanderChangeTime = Time.time + Random.Range(0f, wanderCooldown.y);
            agent.speed = speed;
        }

        void Update()
        {
            if (nextWanderChangeTime < Time.time && enemyStatic.currState != EnemyStatic.State.LOCKED_ON)
            {
                nextWanderChangeTime = Time.time + Random.Range(wanderCooldown.x, wanderCooldown.y);

                Vector3 randDirection = Random.insideUnitSphere * wanderRange;
                randDirection += transform.position;

                NavMeshHit navHit;
                NavMesh.SamplePosition(randDirection, out navHit, wanderRange, -1);

                agent.SetDestination(navHit.position);
            }

            if (agent.velocity == Vector3.zero)
                enemyStatic.enabled = true;
            else
                enemyStatic.enabled = false;
        }
    }
}
