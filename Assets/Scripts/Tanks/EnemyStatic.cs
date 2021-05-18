using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyStatic : Shooter
{
    public float aimSpeed = 210f;
    public float rotCheckTime = 1.5f;
    private float nextRotCheckTime = -1;

    public GameObject upperPart;
    public Vector2 bulletCooldownRange;
    private float nextBulletTime = -1;

    public LayerMask collisionsLayerMask;

    private bool justShot = false;
    private State currState = State.TURNING_RIGHT;

    void Awake()
    {
        nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);
        nextRotCheckTime = Time.time;
    }

    void Update()
    {
        // Aim
        if (nextRotCheckTime < Time.time)
        {
            nextRotCheckTime = Time.time + rotCheckTime;

            //Hits player theoretically?
            bool hitPlayer = false;
            RaycastHit hit;
            if (RaycastWithBounce(bulletSpawnPos.transform.position, bulletSpawnPos.transform.forward, out hit, 999, collisionsLayerMask, 1))
            {
                if (hit.collider.gameObject.GetComponent<PlayerMovement>() != null)
                    hitPlayer = true;
            }
            if (hitPlayer)
                currState = State.NOT_TURNING;
            else
            {
                float rand = Random.value;
                if (rand > 0.7)
                {
                    currState = currState == State.TURNING_LEFT ? currState = State.TURNING_RIGHT : currState = State.TURNING_LEFT;
                }
            }
        }

        //Rotate
        if (justShot && currState == State.NOT_TURNING)
            currState = State.TURNING_LEFT;
        if (currState == State.TURNING_LEFT)
            upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime);
        else if (currState == State.TURNING_RIGHT)
            upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime * -1);

        // Shoot
        justShot = false;
        if (nextBulletTime < Time.time)
        {
            nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);

            RaycastHit hit;
            if (RaycastWithBounce(bulletSpawnPos.transform.position, bulletSpawnPos.transform.forward, out hit, 999, collisionsLayerMask, 1))
            {
                if (hit.collider.gameObject != gameObject)
                {
                    Shoot();
                    justShot = true;
                }
            }
        }
    }

    public static bool RaycastWithBounce(Vector3 origin, Vector3 direction, out RaycastHit hitInfo, float maxDistance, int layerMask, int bounces)
    {
        if (Physics.Raycast(origin, direction, out hitInfo, maxDistance, layerMask))
        {
            Debug.DrawRay(origin, hitInfo.point - origin, Color.green, 1.5f);
            if (bounces > 0)
                return RaycastWithBounce(hitInfo.point, Vector3.Reflect(direction, hitInfo.normal), out hitInfo, maxDistance, layerMask, --bounces);
            return true;
        }
        return false;
    }

    private enum State
    {
        TURNING_LEFT,
        TURNING_RIGHT,
        NOT_TURNING
    }
}
