using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HpController : MonoBehaviour
{
    [SerializeField] private float maxHp = 100f;
    [SerializeField] private float hp = 100f;

    public GameObject spawnOnDeath;

    public Text text;

    void Start()
    {
        hp = maxHp;
        text.text = "" + hp;
    }

    public void ChangeHp(float changeValue)
    {
        hp = Mathf.Clamp(hp + changeValue, 0f, maxHp);
        text.text = "" + hp;

        if (hp <= 0)
        {
            Death();
        }
    }

    void Death()
    {
        if (spawnOnDeath != null)
            Instantiate(spawnOnDeath, transform.position, transform.rotation, GlobalThings.instance.temp);
        Destroy(gameObject);
    }
}
