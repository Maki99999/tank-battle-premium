using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
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

        [SerializeField] private Mode mode = Mode.TURNING;
        public State currState { get; private set; }
        public float maxSwingAngle = 180;
        [SerializeField] private Transform aimingTarget;
        [HideInInspector] public Transform currentTarget;
        [HideInInspector] public float currentTargetOffset;

        protected override void Awake()
        {
            base.Awake();
        }

        private void OnEnable()
        {
            nextBulletTime = Time.time + Random.Range(0f, bulletCooldownRange.y);
            nextRotCheckTime = Time.time;
            nextRaycastTime = Time.time + raycastCheckTime;

            if (mode == Mode.TURNING || mode == Mode.SWINGING)
                currState = Random.value > 0.5 ? State.TURNING_LEFT : State.TURNING_RIGHT;
        }

        void Update()
        {
            if (mode == Mode.IDLE)
                return;
            TestForPlayer();
            Rotate();
            MaybeShoot();
        }

        void TestForPlayer()
        {
            if (mode != Mode.TURNING && mode != Mode.SWINGING)
                return;

            if (nextRaycastTime < Time.time)
            {
                nextRaycastTime = Time.time + raycastCheckTime;

                bool hitsTarget = currentBulletInformation.HitsTarget(bulletSpawnPos, TargetType.LEVEL_PROTECT);
                if (hitsTarget && currState != State.LOCKED_ON)
                {
                    currState = State.LOCKED_ON;
                    nextBulletTime = Time.time + 1f;
                }
                else if (!hitsTarget && currState == State.LOCKED_ON)
                    currState = Random.value > 0.5 ? State.TURNING_LEFT : State.TURNING_RIGHT;
            }
        }

        void Rotate()
        {
            if (mode == Mode.TURNING || mode == Mode.SWINGING)
            {
                if (mode == Mode.TURNING && nextRotCheckTime < Time.time)
                {
                    nextRotCheckTime = Time.time + minRotationTime;
                    if (currState != State.LOCKED_ON && Random.value > 0.7)
                        currState = currState == State.TURNING_LEFT ? currState = State.TURNING_RIGHT : currState = State.TURNING_LEFT;
                }

                if (currState == State.TURNING_LEFT)
                    upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime);
                else if (currState == State.TURNING_RIGHT)
                    upperPart.transform.Rotate(Vector3.up * aimSpeed * Time.deltaTime * -1);

                if (mode == Mode.SWINGING)
                {
                    if (currState == State.TURNING_LEFT && upperPart.transform.eulerAngles.y - 180 <= -maxSwingAngle)
                        currState = State.TURNING_RIGHT;
                    else if (currState == State.TURNING_RIGHT && upperPart.transform.eulerAngles.y - 180 >= maxSwingAngle)
                        currState = State.TURNING_LEFT;
                }
            }
            else if (mode == Mode.AIMING && aimingTarget != null)
            {
                Vector3 lookPos = aimingTarget.position;
                if (currentTarget != null)
                    lookPos = currentTarget.position;

                lookPos = new Vector3(lookPos.x, upperPart.transform.position.y, lookPos.z);

                Vector3 targetDir = lookPos - upperPart.transform.position;
                targetDir.y = 0.0f;
                upperPart.transform.rotation = Quaternion.RotateTowards(upperPart.transform.rotation, Quaternion.AngleAxis(currentTargetOffset, Vector3.up) * Quaternion.LookRotation(targetDir), aimSpeed * Time.deltaTime);
            }
        }

        void MaybeShoot()
        {
            if (nextBulletTime < Time.time)
            {
                nextBulletTime = Time.time + Random.Range(bulletCooldownRange.x, bulletCooldownRange.y);

                if (mode == Mode.STATIC || mode == Mode.AIMING || !currentBulletInformation.HitsTarget(bulletSpawnPos, TargetType.LEVEL_DEFEAT))
                    Shoot();
            }
        }

        public enum State
        {
            TURNING_LEFT,
            TURNING_RIGHT,
            LOCKED_ON
        }

        private enum Mode
        {
            TURNING,
            IDLE,
            STATIC,
            SWINGING,
            AIMING
        }
    }
}