using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class BulletInformation : MonoBehaviour
    {
        const string strTarget = "Target";
        [SerializeField] private float thickness = 0.3f;
        [SerializeField] private int bounces = 1;

        public bool HitsTarget(Transform startPos, TargetType targetType, bool ignoreBounces = false)
        {
            RaycastHit hit;
            return SphereCastTarget(startPos.position, thickness, startPos.forward, out hit, 999, GameController.Instance.collisionsLayerMask, ignoreBounces ? 0 : bounces, targetType);
        }

        private bool SphereCastTarget(Vector3 origin, float radius, Vector3 direction, out RaycastHit hitInfo, float maxDistance, int layerMask, int bounces, TargetType targetType)
        {
            if (Physics.SphereCast(origin, radius, direction, out hitInfo, maxDistance, layerMask))
            {
                Debug.DrawRay(origin, hitInfo.point - origin, Color.green, 1.5f);
                if (hitInfo.collider.gameObject.CompareTag(strTarget))
                {
                    Debug.DrawRay(origin, hitInfo.point - origin, Color.blue, 1.5f);
                    return hitInfo.collider.gameObject.GetComponent<TargetController>().type == targetType;
                }
                if (bounces > 0)
                {
                    Vector3 newOrigin = hitInfo.point;
                    Vector3 correctedNormal = hitInfo.normal;
                    RaycastHit hit;
                    if (Physics.Raycast(origin, direction, out hit, maxDistance, layerMask))
                    {
                        newOrigin = hit.point;
                        correctedNormal = hit.normal;
                    }

                    return SphereCastTarget(newOrigin, radius, Vector3.Reflect(direction, correctedNormal), out hitInfo, maxDistance, layerMask, --bounces, targetType);
                }
            }
            return false;
        }
    }
}
