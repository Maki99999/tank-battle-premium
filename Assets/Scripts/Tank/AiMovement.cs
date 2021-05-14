using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class AiMovement : MonoBehaviour, Shootable
{
    public float speed = 21;
    public float rotSpeed = 210;

    public GameObject bulletSpawnPos;
    public GameObject bulletPrefab;
    public Vector2 bulletCooldownRange;
    public GameObject upperPart;
    public LayerMask rayhitLayer;

    private float nextBulletTime = -1;

    [Space(10)]
    public NavMeshAgent agent;
    public Vector2 wanderCooldown;
    public float wanderRange;

    private float nextWanderChangeTime = -1;

    //TODO: Shoot und Drive (alles mit cooldowns) umaendern auf Corountines;

    void Start()
    {
        nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);
        nextWanderChangeTime = Time.time + Random.Range(wanderCooldown.x, wanderCooldown.y);

        agent.speed = speed;
    }

    void Update()
    {
        // Aim
        if (GlobalThings.instance.player != null)
        {
            Vector3 target = GlobalThings.instance.player.transform.position;
            target = new Vector3(target.x, upperPart.transform.position.y, target.z);
            upperPart.transform.LookAt(target);
        }

        // Shoot
        if (nextBulletTime < Time.time)
        {
            Shoot();
        }

        // Drive
        if (nextWanderChangeTime < Time.time)
        {
            nextWanderChangeTime = Time.time + Random.Range(wanderCooldown.x, wanderCooldown.y);

            Vector3 randDirection = Random.insideUnitSphere * wanderRange;
            randDirection += transform.position;

            NavMeshHit navHit;
            NavMesh.SamplePosition(randDirection, out navHit, wanderRange, -1);

            agent.SetDestination(navHit.position);
        }

        // Turn
        if (agent.velocity.sqrMagnitude > 0.00f)
            transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(agent.velocity, Vector3.up), rotSpeed * Time.deltaTime);
    }

    public void Shoot()
    {
        nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);
        Instantiate(bulletPrefab, bulletSpawnPos.transform.position, bulletSpawnPos.transform.rotation,
                GlobalThings.instance.temp).GetComponent<Bullet>().source = gameObject;

    }

    public void BulletDestroyed() { }
}
