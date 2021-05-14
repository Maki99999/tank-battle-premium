using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 40f;
    public float destroyAfter = 10f;

    public GameObject spawnOnHit;
    public float damage = 10f;
    public int bounces = 1;

    public LayerMask collisionsLayerMask;

    [HideInInspector] public GameObject source;

    private float killTime;

    void Start()
    {
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
        if (coll.gameObject == source)
            return;

        if (coll.gameObject.CompareTag("Target"))
        {
            coll.gameObject.GetComponent<HpController>().ChangeHp(-damage);
            Explode();
        }
        else
        {
            if (bounces <= 0)
                Explode();
            else
            {
                bounces--;

                //Debug.DrawRay(transform.position, transform.forward, Color.blue, 5);

                if (coll.contacts[0].normal.x == 0f && coll.contacts[0].normal.z == 0f)
                {
                    //Debug.DrawRay(transform.position - transform.forward * 1f + Vector3.up * 0.01f, transform.forward * 2f, Color.red);
                    RaycastHit hit;
                    if (Physics.Raycast(transform.position - transform.forward * 1f, transform.forward * 2f, out hit, 2f, collisionsLayerMask))
                        transform.rotation = Quaternion.LookRotation(Vector3.Reflect(transform.forward, hit.normal));
                    else
                        Debug.LogError("OnCollisionEnter fired, but there is no collision?");
                }
                else
                {
                    transform.rotation = Quaternion.LookRotation(Vector3.Reflect(transform.forward, coll.contacts[0].normal));
                }

                //Debug.DrawRay(transform.position + Vector3.up * 0.02f, transform.forward, Color.green, 5);
            }
        }
    }

    void Explode()
    {
        if (source != null)
            source.GetComponent<Shootable>().BulletDestroyed();

        if (spawnOnHit != null)
            Instantiate(spawnOnHit, transform.position, transform.rotation, GlobalThings.instance.temp);
        Destroy(gameObject);
    }
}
