using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public abstract class Shooter : MonoBehaviour
    {
        public Transform bulletSpawnPos;
        public GameObject defaultBulletPrefab;
        private BulletInformation defaultBulletInformation;

        protected GameObject currentBulletPrefab;
        protected BulletInformation currentBulletInformation;

        private int specialBulletAmmo;
        protected int currBulletsOnScreen;

        protected virtual void Awake()
        {
            defaultBulletInformation = defaultBulletPrefab.GetComponent<BulletInformation>();
            currentBulletInformation = defaultBulletInformation;
        }

        public virtual void Shoot()
        {
            if (specialBulletAmmo <= 0)
            {
                currentBulletPrefab = defaultBulletPrefab;
                currentBulletInformation = defaultBulletInformation;
            }
            else
                specialBulletAmmo--;

            currBulletsOnScreen++;
            BulletCollection bulletCollection = Instantiate(currentBulletPrefab, bulletSpawnPos.position,
                    bulletSpawnPos.rotation, GameController.Instance.temp).GetComponent<BulletCollection>();
            bulletCollection.SetSource(this);
        }

        public virtual void BulletDestroyed()
        {
            currBulletsOnScreen--;
            if (currBulletsOnScreen < 0)
                currBulletsOnScreen = 0;
        }

        public void LoadSpecialBullet(GameObject specialBulletPrefab, int specialBulletAmmo)
        {
            this.specialBulletAmmo = specialBulletAmmo;

            currentBulletPrefab = specialBulletPrefab;
            currentBulletInformation = currentBulletPrefab.GetComponent<BulletInformation>();
        }
    }
}
