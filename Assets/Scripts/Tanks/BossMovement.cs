using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace TankBattlePremium
{
    public class BossMovement : MonoBehaviour
    {
        public EnemyStatic enemyStatic;
        public float speed = 21;
        public NavMeshAgent agent;
        public Vector2 wanderCooldown;
        public float wanderRange;
        public Bounds wanderArea;

        private float nextWanderChangeTime = -1;

        private List<Transform> bullets;

        void Start()
        {
            nextWanderChangeTime = Time.time + Random.Range(0f, wanderCooldown.y);
            agent.speed = speed;
        }

        void Update()
        {
            if (nextWanderChangeTime < Time.time)
            {
                nextWanderChangeTime = Time.time + Random.Range(wanderCooldown.x, wanderCooldown.y);

                NavMeshHit navHit;
                NavMesh.SamplePosition(RandomPointInBounds(wanderArea), out navHit, wanderRange, -1);

                agent.SetDestination(navHit.position);
            }
        }

        private void FixedUpdate()
        {
            StartCoroutine(DodgeBullets());
        }

        private void OnTriggerStay(Collider other)
        {
            BulletInformation bulletInformation = other.GetComponent<BulletInformation>();
            if (bulletInformation != null)
            {
                if (bulletInformation.HitsTarget(other.transform, TargetType.LEVEL_DEFEAT, true))
                    bullets.Add(other.gameObject.transform);
            }
            else
                bullets.Add(other.gameObject.transform);
        }

        IEnumerator DodgeBullets()
        {
            bullets = new List<Transform>();
            yield return new WaitForFixedUpdate();

            if (bullets.Count > 0)
            {
                float minAngle = float.MaxValue;
                int minBullet = -1;
                float angleOffset = 0f;

                Vector3 bulletVector = enemyStatic.upperPart.transform.right * 0.3f;
                for (int i = 0; i < bullets.Count; i++)
                {
                    float angle = 180f - Vector3.Angle(enemyStatic.upperPart.transform.forward, bullets[i].forward);
                    if (minBullet == -1 || angle < minAngle)
                    {
                        minAngle = angle;
                        minBullet = i;
                        angleOffset = 0f;
                    }
                    angle = 180f - Vector3.Angle(Quaternion.AngleAxis(-45, Vector3.up) * enemyStatic.upperPart.transform.forward, bullets[i].forward);
                    if (minBullet == -1 || angle < minAngle)
                    {
                        minAngle = angle;
                        minBullet = i;
                        angleOffset = -45;
                    }
                    angle = 180f - Vector3.Angle(Quaternion.AngleAxis(45, Vector3.up) * enemyStatic.upperPart.transform.forward, bullets[i].forward);
                    if (minBullet == -1 || angle < minAngle)
                    {
                        minAngle = angle;
                        minBullet = i;
                        angleOffset = 45;
                    }

                    bulletVector += bullets[i].position - transform.position;
                }
                bulletVector *= -1;

                enemyStatic.currentTarget = bullets[minBullet];
                enemyStatic.currentTargetOffset = angleOffset;

                NavMeshHit navHit;
                NavMesh.SamplePosition(transform.position + bulletVector.normalized, out navHit, wanderRange, -1);
                if (agent != null)
                    agent.SetDestination(navHit.position);
            }
            else
            {
                enemyStatic.currentTarget = null;
                enemyStatic.currentTargetOffset = 0f;
            }
        }

        public static Vector3 RandomPointInBounds(Bounds bounds)
        {
            return new Vector3(
                Random.Range(bounds.min.x, bounds.max.x),
                Random.Range(bounds.min.y, bounds.max.y),
                Random.Range(bounds.min.z, bounds.max.z)
            );
        }
    }
}
