using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class ColorChanger : MonoBehaviour
{
    void Start()
    {
        GetComponent<Renderer>().material.color = Color.clear;
        GetComponent<Renderer>().material.DOColor(Color.white, 1.5f);
    }
}