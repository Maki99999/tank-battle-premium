using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerShootController : MonoBehaviour, Shootable
{
    public GameObject bulletSpawnPos;
    public GameObject bulletPrefab;

    public GameObject upperPart;
    public LayerMask rayhitLayer;

    public float bulletCooldown = 0.5f;
    private float nextBulletTime = -1;

    public int maxBullets;
    private int currBullets;

    void Start()
    {
        nextBulletTime = Time.time + bulletCooldown;
    }

    void Update()
    {
        // Aim
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, Mathf.Infinity, rayhitLayer))
        {
            Vector3 hitAdjusted = hit.point;
            hitAdjusted = new Vector3(hitAdjusted.x, upperPart.transform.position.y, hitAdjusted.z);
            upperPart.transform.LookAt(hitAdjusted);
        }

        // Shoot
        if (Input.GetKeyDown(KeyCode.Mouse0) && Time.time > nextBulletTime && currBullets < maxBullets)   //TODO: Input
        {
            Shoot();
        }
    }

    public void Shoot()
    {
        nextBulletTime = Time.time + bulletCooldown;

        currBullets++;
        Instantiate(bulletPrefab, bulletSpawnPos.transform.position, bulletSpawnPos.transform.rotation,
                GameController.Instance.temp).GetComponent<Bullet>().SetSource(gameObject, this);
    }

    public void BulletDestroyed()
    {
        currBullets--;
        if (currBullets < 0)
            currBullets = 0;
    }
}
