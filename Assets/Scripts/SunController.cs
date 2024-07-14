using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class SunController : MonoBehaviour
{
    public float rotationStartValue;
    public float rotationEndValue;
    public float duration;
    Vector3 rotation;

    float intensity;
    public float highestIntensity;
    public float lowestIntensity;

    public Material Skybox;
    float exposure;
    public float highestExposure;
    public float lowestExposure;

    private void Start()
    {
        intensity = highestIntensity;
        RenderSettings.skybox = Skybox;
        Skybox.SetFloat("_Exposure", highestExposure);
    }
    public void SunChanger(Sequence sequence)
    {
        rotation = transform.localRotation.eulerAngles;
        sequence.Append(transform.DORotate(new Vector3(rotationEndValue, rotation.y, rotation.z), duration));
        sequence.AppendInterval(2f);
        sequence.Append(transform.DORotate(new Vector3(rotationStartValue, rotation.y, rotation.z), duration));
    }
    public void AmbientLightChanger(Sequence sequence)
    {
        sequence.Append(DOTween.To(() => intensity, x => intensity = x, lowestIntensity, duration));
        sequence.Join(Skybox.DOFloat(lowestExposure, "_Exposure", duration));
        sequence.AppendInterval(2f);
        sequence.Append(DOTween.To(() => intensity, x => intensity = x, highestIntensity, duration));
        sequence.Join(Skybox.DOFloat(highestExposure, "_Exposure", duration));
    }
    private void Update()
    {
        RenderSettings.ambientIntensity = intensity;
    }
}
