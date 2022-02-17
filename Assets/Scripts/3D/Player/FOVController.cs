using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    [RequireComponent(typeof(Camera))]
    public class FOVController : MonoBehaviour
    {
        [HideInInspector] public bool isSprinting;
        [HideInInspector] public bool isZooming;

        [SerializeField] private float normalFoV = 60f;
        [SerializeField] private float zoomFoV = 30f;
        [SerializeField] private float sprintingFoV = 65f;
        private float currentFoV;

        new private Camera camera;

        private void Start()
        {
            currentFoV = 60f;
            camera = GetComponent<Camera>();
        }

        private void Update()
        {
            float desiredFoV = normalFoV;
            if (isZooming)
                desiredFoV = zoomFoV;
            if (isSprinting)
                desiredFoV = sprintingFoV;

            currentFoV = Mathf.Lerp(currentFoV, desiredFoV, 0.075f);
            if (desiredFoV - 0.1f < currentFoV && currentFoV < desiredFoV + 0.1f)
                currentFoV = desiredFoV;

            camera.fieldOfView = currentFoV;
        }
    }
}
