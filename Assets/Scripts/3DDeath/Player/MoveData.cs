using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TankBattlePremium 
{
    [System.Serializable]
    public class MoveData
    {
        public float xRot = 0f;             //Mouse X
        public float yRot = 0f;             //Mouse Y
        public float axisVertical = 0f;     //Forward/Backwards
        public float axisHorizontal = 0f;   //Left/Right
        public float axisSneak = 0f;        //Sneak
        public float axisSprint = 0f;       //Sprint
        public float axisJump = 0f;         //Jump
        public float axisPrimary = 0f;      //Primary Fire Key
        public float axisSecondary = 0f;    //Secondary Fire Key
    }
}
