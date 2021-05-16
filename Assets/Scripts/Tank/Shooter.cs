using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Shooter : MonoBehaviour
{
    public GameObject bulletSpawnPos;
    public GameObject defaultBulletPrefab;
    public GameObject specialBulletPrefab;
    public int specialBulletAmmo;
    protected int currBullets;

    public virtual void Shoot()
    {
        GameObject bulletPrefab = defaultBulletPrefab;
        if (specialBulletPrefab != null && specialBulletAmmo > 0)
        {
            specialBulletAmmo--;
            bulletPrefab = specialBulletPrefab;
        }

        currBullets++;
        BulletCollection bulletCollection = Instantiate(bulletPrefab, bulletSpawnPos.transform.position,
                bulletSpawnPos.transform.rotation, GameController.Instance.temp).GetComponent<BulletCollection>();
        bulletCollection.SetSource(this);
    }

    public virtual void BulletDestroyed()
    {
        currBullets--;
        if (currBullets < 0)
            currBullets = 0;
    }
}
