using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public float speed = 21;
    public float rotSpeed = 210;

    public CharacterController charController;

    void Update()
    {
        // Move
        float x = Input.GetAxisRaw("Horizontal");
        float z = Input.GetAxisRaw("Vertical");

        Vector3 movement = new Vector3(x, 0, z).normalized;
        movement *= speed * Time.deltaTime;

        //transform.position += movement;
        charController.Move(movement);

        // Turn
        if (movement.sqrMagnitude > 0.00f)
            transform.rotation = Quaternion.RotateTowards(transform.rotation,
                    Quaternion.LookRotation(movement, Vector3.up), rotSpeed * Time.deltaTime);
    }
}
