using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 40f;
    public float destroyAfter = 60f;

    public float gracePeriodTimeSource = 0.2f;
    private float fireTime;

    public GameObject spawnOnHit;
    public float damage = 10f;
    public int bounces = 1;

    public LayerMask collisionsLayerMask;

    private GameObject sourceObject;
    private Shootable sourceScript;

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

    public void SetSource(GameObject sourceObject, Shootable sourceScript)
    {
        if (sourceObject == null || sourceScript == null)
            return;

        this.sourceObject = sourceObject;
        this.sourceScript = sourceScript;
    }

    void OnCollisionEnter(Collision coll)
    {
        if (coll.gameObject == sourceObject && Time.time < fireTime + gracePeriodTimeSource)
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

                if (coll.contacts[0].normal.x == 0f && coll.contacts[0].normal.z == 0f)
                {
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
            }
        }
    }

    void Explode()
    {
        if (spawnOnHit != null)
            Instantiate(spawnOnHit, transform.position, transform.rotation, GameController.Instance.temp);
        Destroy(gameObject);
    }

    void OnDestroy()
    {
        if (sourceObject != null)
            sourceScript.BulletDestroyed();
    }
}
