using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyStatic : Shooter
{
    public float aimSpeed = 210f;
    public float minRotationTime = 3f;
    public float raycastCheckTime = 0.1f;
    private float nextRotCheckTime;
    private float nextRaycastTime;

    public GameObject upperPart;
    public Vector2 bulletCooldownRange;
    private float nextBulletTime;

    public TargetController targetController;

    private State currState;

    protected override void Awake()
    {
        base.Awake();
        nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);
        nextRotCheckTime = Time.time;
        nextRaycastTime = Time.time + raycastCheckTime;

        currState = Random.value > 0.5 ? State.TURNING_LEFT : State.TURNING_RIGHT;
    }

    void Update()
    {
        TestForPlayer();
        Rotate();
        MaybeShoot();
    }

    void TestForPlayer()
    {
        if (nextRaycastTime < Time.time)
        {
            nextRaycastTime = Time.time + raycastCheckTime;

            //Hits player?
            if (currState != State.NOT_TURNING && currentBulletInformation.HitsTarget(bulletSpawnPos, TargetType.LEVEL_PROTECT))
            {
                currState = State.NOT_TURNING;
                nextBulletTime = Time.time + 1f;
            }
        }
    }

    void Rotate()
    {
        if (nextRotCheckTime < Time.time)
        {
            nextRotCheckTime = Time.time + minRotationTime;
            if (currState != State.NOT_TURNING && Random.value > 0.7)
                currState = currState == State.TURNING_LEFT ? currState = State.TURNING_RIGHT : currState = State.TURNING_LEFT;
        }

        if (currState == State.TURNING_LEFT)
            upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime);
        else if (currState == State.TURNING_RIGHT)
            upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime * -1);
    }

    void MaybeShoot()
    {
        if (nextBulletTime < Time.time)
        {
            nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);

            if (currState == State.NOT_TURNING)
                currState = Random.value > 0.5 ? State.TURNING_LEFT : State.TURNING_RIGHT;

            if (!currentBulletInformation.HitsTarget(bulletSpawnPos, TargetType.LEVEL_DEFEAT))
            {
                Shoot();
            }
        }
    }

    /*public static bool RaycastWithBounce(Vector3 origin, Vector3 direction, out RaycastHit hitInfo, float maxDistance, int layerMask, int bounces, System.Func<RaycastHit, bool> CheckOnBounce)
    {
        if (Physics.Raycast(origin, direction, out hitInfo, maxDistance, layerMask))
        {
            Debug.DrawRay(origin, hitInfo.point - origin, Color.green, 1.5f);
            if (CheckOnBounce(hitInfo))
            {
                Debug.DrawRay(origin, hitInfo.point - origin, Color.blue, 1.5f);
                return true;
            }
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
    }*/

    private enum State
    {
        TURNING_LEFT,
        TURNING_RIGHT,
        NOT_TURNING
    }
}
