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

        protected override void Awake()
        {
            base.Awake();
        }

        private void OnEnable()
        {
            nextBulletTime = Time.time + Random.Range(0f, bulletCooldownRange.y);
            nextRotCheckTime = Time.time;
            nextRaycastTime = Time.time + raycastCheckTime;

            currState = Random.value > 0.5 ? State.TURNING_LEFT : State.TURNING_RIGHT;
        }

        void Update()
        {
            if (mode == Mode.IDLE)
                return;
            if (mode == Mode.TURNING)
                TestForPlayer();
            if (mode == Mode.TURNING)
                Rotate();
            MaybeShoot();
        }

        void TestForPlayer()
        {
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
            if (nextRotCheckTime < Time.time)
            {
                nextRotCheckTime = Time.time + minRotationTime;
                if (currState != State.LOCKED_ON && Random.value > 0.7)
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

                if (mode == Mode.STATIC || !currentBulletInformation.HitsTarget(bulletSpawnPos, TargetType.LEVEL_DEFEAT))
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
            STATIC
        }
    }
}