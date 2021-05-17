using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Credits : MonoBehaviour
{
    public TextMeshProUGUI textElement;

    public TextAsset creditsText;

    private void Awake() {
        textElement.text = creditsText.text;
    }
}
