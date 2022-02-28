using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class Ghost : MonoBehaviour
    {
        public float safeRange = 7f;
        public float maxRangeWaitAndAttack = 14f;
        public float maxRangeChargeOnLook = 21f;
        public float maxRangeJustStare = 30f;

        public AudioSource crySfx;
        public LayerMask layerMask;
        public Animator ghostAnim;

        private Transform player;
        private Transform cam;
        private DeathController deathController;

        void Start()
        {
            StartCoroutine(AudioFx());
            player = GameObject.FindWithTag("Player").transform;
            cam = player.GetChild(0).GetChild(0);
            deathController = GameObject.FindWithTag("GameController").GetComponent<DeathController>();
        }

        private void Update()
        {
            ghostAnim.SetFloat("speed", Random.Range(.5f, 2f));
        }

        IEnumerator AudioFx()
        {
            yield return new WaitForSeconds(2f);
            while (enabled)
            {
                //teleport, appear
                Vector2 randomPoint = Random.insideUnitCircle;
                Vector3 oldPos = player.position +
                        new Vector3(randomPoint.x * (maxRangeJustStare - safeRange) + Mathf.Sign(randomPoint.x) * randomPoint.x * safeRange,
                        -2f,
                        randomPoint.y * (maxRangeJustStare - safeRange) + Mathf.Sign(randomPoint.y) * randomPoint.y * safeRange);
                Vector3 newPos = new Vector3(oldPos.x, 0, oldPos.z);

                float rate = 1f / 2f;
                float fSmooth;
                for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
                {
                    fSmooth = Mathf.SmoothStep(0f, 1f, f);
                    transform.position = Vector3.Lerp(oldPos, newPos, fSmooth);
                    yield return null;
                }

                //wait for playerInteraction (look or inRange)
                float range = (newPos - player.position).magnitude;
                int mode = range < maxRangeWaitAndAttack ? 2 : range < maxRangeChargeOnLook ? 1 : 0;
                float rate2 = 1f / Random.Range(10f, 25f);
                for (float f = 0f; f <= 1f; f += rate2 * Time.deltaTime)
                {
                    if (mode != 0)
                    {
                        if (mode == 1)
                        {
                            RaycastHit hit;
                            if (Physics.Raycast(cam.transform.position, cam.forward, out hit, maxRangeJustStare, layerMask))
                            {
                                if (hit.collider.gameObject.CompareTag("Target"))
                                {
                                    mode = 3;
                                    ghostAnim.SetBool("Attack", true);
                                    crySfx.Play();
                                }
                            }
                        }
                        else if (mode == 3)
                        {
                            float rate3 = 1f / .75f;
                            for (float f3 = 0f; f3 <= 0.96f; f3 += rate3 * Time.deltaTime)
                            {
                                transform.position = Vector3.Lerp(newPos, player.position, f3);
                                yield return null;
                            }
                            transform.position = oldPos;
                            break;
                        }
                    }
                    if ((transform.position - player.position).sqrMagnitude < safeRange * safeRange)
                    {
                        mode = 3;
                        ghostAnim.SetBool("Attack", true);
                        crySfx.Play();
                    }
                    yield return null;
                }

                //disappear
                if (mode != 3)
                    for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
                    {
                        fSmooth = Mathf.SmoothStep(0f, 1f, f);
                        transform.position = Vector3.Lerp(newPos, oldPos, fSmooth);
                        yield return null;
                    }

                ghostAnim.SetBool("Attack", false);
                yield return new WaitForSeconds(Random.Range(2f, 12f));
            }
        }
    }
}
