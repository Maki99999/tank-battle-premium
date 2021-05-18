using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyStatic : Shooter
{
    public float aimSpeed = 210f;
    public float rotCheckTime = 1.5f;
    private float nextRotCheckTime = -1;

    public GameObject upperPart;
    public Vector2 bulletCooldownRange;
    private float nextBulletTime = -1;

    public TargetController targetController;
    public LayerMask collisionsLayerMask;

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
            RaycastHit hit;
            if (RaycastWithBounce(bulletSpawnPos.transform.position, bulletSpawnPos.transform.forward, out hit, 999, collisionsLayerMask, 1, (h) => HitPlayer(h)) && HitPlayer(hit))
            {
                currState = State.NOT_TURNING;
            }
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
        if (currState == State.TURNING_LEFT)
            upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime);
        else if (currState == State.TURNING_RIGHT)
            upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime * -1);

        // Shoot
        if (nextBulletTime < Time.time)
        {
            nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);

            RaycastHit hit;
            if (RaycastWithBounce(bulletSpawnPos.transform.position, bulletSpawnPos.transform.forward, out hit, 999, collisionsLayerMask, 1, (h) => HitFriendly(h)) && !HitFriendly(hit))
            {
                Shoot();
                if (currState == State.NOT_TURNING)
                    currState = State.TURNING_LEFT;
            }
        }
    }

    public static bool RaycastWithBounce(Vector3 origin, Vector3 direction, out RaycastHit hitInfo, float maxDistance, int layerMask, int bounces, System.Func<RaycastHit, bool> CheckOnBounce)
    {
        if (Physics.Raycast(origin, direction, out hitInfo, maxDistance, layerMask))
        {
            Debug.DrawRay(origin, hitInfo.point - origin, Color.green, 1.5f);
            if (CheckOnBounce(hitInfo))
                return true;
            if (bounces > 0)
                return RaycastWithBounce(hitInfo.point, Vector3.Reflect(direction, hitInfo.normal), out hitInfo, maxDistance, layerMask, --bounces, CheckOnBounce);
            return true;
        }
        return false;
    }

    private bool HitPlayer(RaycastHit hit)
    {
        return hit.collider.gameObject.GetComponent<PlayerMovement>() != null;
    }

    private bool HitFriendly(RaycastHit hit)
    {
        TargetController target = hit.collider.gameObject.GetComponent<TargetController>();
        return target != null && target.type == targetController.type;
    }

    private enum State
    {
        TURNING_LEFT,
        TURNING_RIGHT,
        NOT_TURNING
    }
}
