using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletPowerUp : MonoBehaviour
{
    public GameObject bulletPrefab;
    public int ammo = 1;

    private void OnTriggerEnter(Collider other)
    {
        Shooter shooter = other.GetComponent<Shooter>();
        if (shooter != null)
        {
            shooter.specialBulletPrefab = bulletPrefab;
            shooter.specialBulletAmmo = ammo;

            Destroy(gameObject);
        }
    }
}
