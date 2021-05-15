using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[System.Serializable]
public class BooleanWrapper : System.Object
{
    public BooleanWrapper(bool val = false) { Value = val; }
    public bool Value { get; set; }
}
