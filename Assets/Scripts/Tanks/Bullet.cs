using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class Bullet : BulletCollection
    {
        public float speed = 40f;
        public float destroyAfter = 60f;

        public float gracePeriodTimeSource = 0.2f;
        private float fireTime;

        public GameObject spawnOnHit;
        public float damage = 10f;
        public int bounces = 1;
        private bool justBounced = false;

        private float killTime;

        void Start()
        {
            fireTime = Time.time;
            killTime = Time.time + destroyAfter;
        }

        void Update()
        {
            transform.position += transform.forward * speed * Time.deltaTime;

            if (Time.time > killTime)
                Explode();
        }

        void OnCollisionEnter(Collision coll)
        {
            justBounced = true;
            Collision(coll);
        }

        void Collision(Collision coll)
        {

            if (sourceScript != null && coll.gameObject == sourceScript.gameObject && Time.time < fireTime + gracePeriodTimeSource)
                return;

            if (coll.gameObject.CompareTag("Target"))
            {
                coll.gameObject.GetComponent<TargetController>().ChangeHp(-damage);
                Explode();
            }
            else
            {
                if (bounces-- <= 0)
                    Explode();
                else
                {
                    Vector3 oldForward = transform.forward;
                    Debug.DrawRay(transform.position, transform.forward, Color.red, 1f);

                    Vector3 newPos = transform.position;
                    Vector3 normal = GetHitNormalFromRaycast(transform.position - transform.forward * 2f, transform.forward, 4f, out newPos);
                    transform.rotation = Quaternion.LookRotation(Vector3.Reflect(transform.forward, normal));

                    if (oldForward == transform.forward)
                    {
                        normal = GetHitNormalFromRaycast(transform.position + transform.right * 0.35f - transform.forward * 2f, transform.forward, 4f, out newPos);
                        if (normal != Vector3.zero)
                            transform.rotation = Quaternion.LookRotation(Vector3.Reflect(transform.forward, normal));

                        if (oldForward == transform.forward)
                        {
                            normal = GetHitNormalFromRaycast(transform.position - transform.right * 0.35f - transform.forward * 2f, transform.forward, 4f, out newPos);
                            if (normal != Vector3.zero)
                                transform.rotation = Quaternion.LookRotation(Vector3.Reflect(transform.forward, normal));
                        }
                    }

                    transform.position = newPos;

                    Debug.DrawRay(transform.position, normal, Color.blue, 1f);
                    Debug.DrawRay(transform.position, transform.forward, Color.green, 1f);
                }
            }
        }

        Vector3 GetHitNormalFromRaycast(Vector3 position, Vector3 direction, float maxDistance, out Vector3 hitPosition)
        {
            Vector3 normal = Vector3.zero;
            hitPosition = Vector3.zero;

            Debug.DrawRay(position, direction * maxDistance, Color.gray, 1f);
            RaycastHit hit;
            if (Physics.Raycast(position, direction * maxDistance, out hit, maxDistance, GameController.Instance.collisionsLayerMask))
            {
                normal = hit.normal;
                Debug.DrawRay(transform.position, hit.normal, Color.blue, 1f);
            }

            hitPosition = hit.point;
            return normal;
        }

        void OnCollisionStay(Collision coll)
        {
            if (!justBounced)
            {
                justBounced = true;
                Collision(coll);
            }
        }

        void OnCollisionExit(Collision coll)
        {
            justBounced = false;
        }

        void Explode()
        {
            if (spawnOnHit != null)
                Instantiate(spawnOnHit, transform.position, transform.rotation, GameController.Instance.temp);
            Destroy(gameObject);
        }

        void OnDestroy()
        {
            BulletDestroyed();
        }
    }
}
