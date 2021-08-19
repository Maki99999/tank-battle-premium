using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class BulletCollection : MonoBehaviour
    {
        protected Shooter sourceScript;

        private int bulletCount = 1;

        private List<BulletCollection> subBulletCollections = new List<BulletCollection>();

        void Start()
        {
            for (int i = 0; i < transform.childCount; i++)
            {
                BulletCollection bulletCollection = transform.GetChild(i).GetComponent<BulletCollection>();
                if (bulletCollection != null)
                {
                    subBulletCollections.Add(bulletCollection);
                    bulletCollection.SetSource(sourceScript);
                }
            }
            bulletCount = subBulletCollections.Count;
        }

        public void SetSource(Shooter sourceScript)
        {
            if (sourceScript == null)
                return;

            this.sourceScript = sourceScript;

            foreach (BulletCollection bulletCollection in subBulletCollections)
                bulletCollection.SetSource(sourceScript);
        }

        protected void BulletDestroyed()
        {
            if (--bulletCount <= 0)
            {
                BulletCollection parentBC = transform.parent.GetComponent<BulletCollection>();
                if (parentBC != null)
                    parentBC.BulletDestroyed();
                else if (sourceScript != null && sourceScript.gameObject != null)
                    sourceScript.BulletDestroyed();
                Destroy(gameObject);
            }
        }
    }
}
