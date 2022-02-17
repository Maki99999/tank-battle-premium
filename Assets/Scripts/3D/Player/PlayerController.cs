using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium
{
    public class PlayerController : MonoBehaviour
    {
        [HideInInspector] public Transform focusedObject;
        [Space(20)]
        public float mouseSensitivityX = 2f;
        public float mouseSensitivityY = 2f;
        [Space(10)]
        public float speedNormal = 5f;
        public float speedSneaking = 2f;
        public float speedSprinting = 8f;
        public float jumpForce = 1f;
        float speedCurrent = 0f;
        public float gravity = 10f;
        public float airControl = 1f;
        Vector3 moveDirection = Vector3.zero;
        [Space(10)]
        public float heightNormal = 1.8f;
        public float heightSneaking = 1.4f;
        public float camOffsetHeight = 0.2f;
        public float camOffsetX = 0f;
        public float camOffsetY = 0f;
        public FOVController fOVController;
        [Space(10), SerializeField]
        private int frozenSem = 0;
        [HideInInspector] public bool canControl = true;
        public bool isSneaking = false;
        public bool isSprinting = false;
        [Space(10)]
        public GameObject crosshair;

        public CharacterController charController;
        public Transform eyeHeightTransform;
        public Camera cam;
        public UseController useController;

        public Transform itemHoldPosition;
        private List<string> items = new List<string>();

        private LayerMask myLayerMask;

        void Awake()
        {
            myLayerMask = 1 << gameObject.layer;
        }

        void Start()
        {
            eyeHeightTransform.localPosition = new Vector3(0f, heightNormal - camOffsetHeight, 0f);

            speedCurrent = speedNormal;

            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
            Time.timeScale = 1;
            SetFrozen(false);
        }

        void Update()
        {
            //Apply Camera Effects
            CameraEffects();

            //Do nothing when Player isn't allowed to move
            if (IsFrozen())
                return;

            MoveData inputs;
            if (canControl)
            {
                //Get Inputs
                inputs = new MoveData()
                {
                    xRot = Input.GetAxis("Mouse Y") * mouseSensitivityY,
                    yRot = Input.GetAxis("Mouse X") * mouseSensitivityX,
                    axisHorizontal = Input.GetAxisRaw("Horizontal"),
                    axisVertical = Input.GetAxisRaw("Vertical"),
                    axisSneak = Input.GetAxisRaw("Control"),
                    axisSprint = Input.GetAxisRaw("Shift"),
                    axisJump = Input.GetAxisRaw("Space"),
                    axisPrimary = Input.GetAxisRaw("Primary"),
                    axisSecondary = Input.GetAxisRaw("Secondary")
                };
            }
            else
            {
                inputs = new MoveData();
            }

            if (focusedObject == null)
                Rotate(inputs.xRot, inputs.yRot);
            else
                FocusObject();
            Move(inputs);
        }

        void Rotate(float xRot, float yRot)
        {
            Quaternion characterTargetRot = transform.localRotation;
            Quaternion cameraTargetRot = eyeHeightTransform.localRotation;

            characterTargetRot *= Quaternion.Euler(0f, yRot, 0f);
            cameraTargetRot *= Quaternion.Euler(-xRot, 0f, 0f);

            cameraTargetRot = ClampRotationAroundXAxis(cameraTargetRot);

            transform.localRotation = characterTargetRot;
            eyeHeightTransform.localRotation = cameraTargetRot;
        }

        void FocusObject()
        {
            Quaternion oldRot = Quaternion.Euler(eyeHeightTransform.localEulerAngles.x, transform.localEulerAngles.y, 0f);
            Quaternion newRot = Quaternion.LookRotation(focusedObject.position - eyeHeightTransform.position);

            Quaternion targetRot = Quaternion.Lerp(oldRot, newRot, 8f * Time.deltaTime);

            transform.localEulerAngles = new Vector3(0, targetRot.eulerAngles.y, 0);
            eyeHeightTransform.localEulerAngles = new Vector3(targetRot.eulerAngles.x, 0, 0);
        }

        void Move(MoveData inputs)
        {
            //Changes camera height and speed while sneaking
            if (inputs.axisSneak > 0)
            {
                if (!isSneaking)
                    StartCoroutine(Sneak(true));

                if (isSprinting)
                    Sprint(false);
            }
            else
            {
                if (isSneaking)
                    StartCoroutine(Sneak(false));

                if (!isSneaking)
                {
                    //Changes camera FOV and speed while sprinting
                    if (inputs.axisSprint > 0 && inputs.axisVertical > 0)
                    {
                        if (!isSprinting)
                            Sprint(true);
                    }
                    else
                    {
                        if (isSprinting)
                            Sprint(false);
                    }
                }
            }
            speedCurrent = isSneaking ? speedSneaking : isSprinting ? speedSprinting : speedNormal;

            //Normalize input and add speed
            Vector2 input = new Vector2(inputs.axisHorizontal, inputs.axisVertical);
            input.Normalize();
            input *= speedCurrent;

            //Jump and Gravity
            if (charController.isGrounded)
            {
                moveDirection = transform.forward * input.y + transform.right * input.x;
                if (inputs.axisJump > 0)
                    moveDirection.y = jumpForce;
            }
            else
            {
                input *= airControl;
                moveDirection = transform.forward * input.y + transform.right * input.x + transform.up * moveDirection.y;
            }

            moveDirection.y -= gravity * (Time.deltaTime / 2);

            Vector3 oldPos = transform.position;
            charController.Move(moveDirection * Time.deltaTime);
            Vector3 newPos = transform.position;

            moveDirection.y -= gravity * (Time.deltaTime / 2);
        }

        void CameraEffects()
        {
            if (camOffsetX != 0f || camOffsetY != 0f)
                eyeHeightTransform.localPosition = new Vector3(camOffsetX, camOffsetY, 0f);
        }

        IEnumerator Sneak(bool willSneak)
        {
            isSneaking = willSneak;
            charController.height = willSneak ? heightSneaking : heightNormal;
            charController.center = Vector3.up * (charController.height / 2f);

            Vector3 oldCamPos = eyeHeightTransform.localPosition;
            float newHeight = willSneak ? heightSneaking - camOffsetHeight : heightNormal - camOffsetHeight;

            for (float i = 0; i < 1 && (isSneaking == willSneak); i += 0.2f)
            {
                eyeHeightTransform.localPosition = Vector3.Lerp(oldCamPos, new Vector3(0f, newHeight, 0f), i);
                yield return new WaitForSeconds(1f / 60f);
            }
            if (isSneaking == willSneak)
                eyeHeightTransform.localPosition = new Vector3(0f, newHeight, 0f);
        }

        private void Sprint(bool willSprint)
        {
            isSprinting = willSprint;
            fOVController.isSprinting = willSprint;
        }

        public bool IsFrozen() { return frozenSem <= 0; }

        public void SetFrozen(bool frozen)
        {
            frozenSem += frozen ? -1 : 1;

            if (frozenSem > 1)
            {
                frozenSem = 1;
                Debug.LogWarning(gameObject.name + " got unfrozen twice!");
            }
            else if (frozenSem == 1)
            {
                charController.detectCollisions = true;
                crosshair.SetActive(true);
                useController.enabled = true;
            }
            else if (frozenSem == 0)
            {
                charController.detectCollisions = false;
                crosshair.SetActive(false);
                useController.enabled = false;

                Sprint(false);
                StartCoroutine(Sneak(false));
            }
        }

        public void TeleportPlayer(Transform newPosition, bool cameraPerspective = false, Vector3 offset = new Vector3())
        {
            if (isSprinting)
                Sprint(false);
            float heightOffset = 0f;
            if (isSneaking && cameraPerspective)
            {
                isSneaking = false;
                charController.height = heightNormal;
                heightOffset = heightNormal - camOffsetHeight - eyeHeightTransform.localPosition.y;
                eyeHeightTransform.localPosition = new Vector3(0f, heightNormal - camOffsetHeight, 0f);
            }

            Vector3 positionNew = newPosition.position + offset;
            if (cameraPerspective)
                positionNew -= (isSneaking ? heightSneaking - camOffsetHeight : heightNormal - camOffsetHeight) * Vector3.up;

            bool oldCCState = charController.enabled;
            charController.enabled = false;

            transform.position = positionNew;
            transform.rotation = Quaternion.Euler(0f, newPosition.rotation.eulerAngles.y, 0f);
            eyeHeightTransform.localRotation = Quaternion.Euler(newPosition.rotation.eulerAngles.x, 0f, 0f);

            charController.enabled = oldCCState;
        }

        public IEnumerator MoveRotatePlayer(Transform newPosition, float seconds = 2f, bool cameraPerspective = false, Vector3 offset = new Vector3())
        {
            if (isSprinting)
                Sprint(false);
            float heightOffset = 0f;
            if (isSneaking && cameraPerspective)
            {
                isSneaking = false;
                charController.height = heightNormal;
                heightOffset = heightNormal - camOffsetHeight - eyeHeightTransform.localPosition.y;
                eyeHeightTransform.localPosition = new Vector3(0f, heightNormal - camOffsetHeight, 0f);
            }

            Vector3 positionNew = newPosition.position + offset;
            if (cameraPerspective)
                positionNew -= (isSneaking ? heightSneaking - camOffsetHeight : heightNormal - camOffsetHeight) * Vector3.up;

            var mov = StartCoroutine(MovePlayer(positionNew, seconds, cameraPerspective));
            var rot = StartCoroutine(RotatePlayer(newPosition.rotation, seconds));

            yield return mov;
            yield return rot;
        }

        public IEnumerator MovePlayer(Vector3 newPosition, float seconds = 2f, bool ignoreSneak = false)
        {
            if (isSprinting)
                Sprint(false);
            if (isSneaking && !ignoreSneak)
                StartCoroutine(Sneak(false));

            Vector3 positionOld = transform.position;

            float rate = 1f / seconds;
            float fSmooth;
            for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
            {
                fSmooth = Mathf.SmoothStep(0f, 1f, f);
                transform.position = Vector3.Lerp(positionOld, newPosition, fSmooth);

                yield return null;
            }

            transform.position = newPosition;
        }

        public IEnumerator RotatePlayer(Quaternion newRotation, float seconds = 2f)
        {
            if (isSprinting)
                Sprint(false);

            Quaternion rotationPlayerOld = transform.rotation;
            Quaternion rotationCameraOld = eyeHeightTransform.localRotation;

            Quaternion rotationPlayerNew = Quaternion.Euler(0f, newRotation.eulerAngles.y, 0f);
            Quaternion rotationCameraNew = Quaternion.Euler(newRotation.eulerAngles.x, 0f, 0f);

            float rate = 1f / seconds;
            float fSmooth;
            for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
            {
                fSmooth = Mathf.SmoothStep(0f, 1f, f);
                eyeHeightTransform.localRotation = Quaternion.Lerp(rotationCameraOld, rotationCameraNew, fSmooth);
                transform.rotation = Quaternion.Lerp(rotationPlayerOld, rotationPlayerNew, fSmooth);

                yield return null;
            }

            eyeHeightTransform.localRotation = rotationCameraNew;
            transform.rotation = rotationPlayerNew;
        }

        public IEnumerator LookAt(Vector3 lookAtPos, float seconds = 2f)
        {
            yield return RotatePlayer(Quaternion.LookRotation(lookAtPos - eyeHeightTransform.position), seconds);
        }

        public void SetRotationLerp(Vector3 a, Vector3 b, float t)
        {
            Quaternion a1 = Quaternion.Euler(0f, a.y, 0f);
            Quaternion a2 = Quaternion.Euler(a.x, 0f, 0f);
            Quaternion b1 = Quaternion.Euler(0f, b.y, 0f);
            Quaternion b2 = Quaternion.Euler(b.x, 0f, 0f);

            transform.rotation = Quaternion.Lerp(a1, b1, t);
            eyeHeightTransform.localRotation = Quaternion.Lerp(a2, b2, t);
        }

        public Vector3 GetRotation()
        {
            return new Vector3(eyeHeightTransform.localEulerAngles.x, transform.eulerAngles.y, 0f);
        }

        Quaternion ClampRotationAroundXAxis(Quaternion q)
        {
            q.x /= q.w;
            q.y /= q.w;
            q.z /= q.w;
            q.w = 1.0f;

            float angleX = 2.0f * Mathf.Rad2Deg * Mathf.Atan(q.x);
            angleX = Mathf.Clamp(angleX, -90, 90);
            q.x = Mathf.Tan(0.5f * Mathf.Deg2Rad * angleX);

            return q;
        }

        private IEnumerator SmoothPickup(Transform item, string itemName, float seconds = 1f)
        {
            useController.enabled = false;

            Vector3 oldPos = item.transform.localPosition;
            Quaternion oldRot = item.transform.localRotation;
            Vector3 oldScale = item.transform.localScale;

            float rate = 1f / seconds;
            float fSmooth;
            for (float f = 0f; f <= 1f; f += rate * Time.deltaTime)
            {
                fSmooth = Mathf.SmoothStep(0f, 1f, f);

                item.transform.position = Vector3.Lerp(oldPos, itemHoldPosition.position, fSmooth);
                item.transform.rotation = Quaternion.Lerp(oldRot, itemHoldPosition.rotation, fSmooth);
                item.transform.localScale = Vector3.Lerp(oldScale, itemHoldPosition.localScale, fSmooth);

                yield return null;
            }

            item.transform.position = itemHoldPosition.position;
            item.transform.rotation = itemHoldPosition.rotation;
            item.transform.localScale = itemHoldPosition.localScale;

            items.Add(itemName);
            useController.enabled = true;
        }

        public void RemoveItem(string itemName)
        {
            items.Remove(itemName);
        }
    }
}
