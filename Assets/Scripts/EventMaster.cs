using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class EventMaster : MonoBehaviour
{
    SunController sunController;
    Material oldPhoto;
    MeshRenderer photoframe;
    public int index = 0;
    public List<Material> newPhoto = new List<Material>();
    public List<GameObject> notes = new List<GameObject>();
    public GameObject nextDay;
    // Start is called before the first frame update
    void Start()
    {
        photoframe = GameObject.Find("PhotoFrame").GetComponent<MeshRenderer>();
        oldPhoto = photoframe.material;
        sunController = GameObject.Find("Directional Light").GetComponent<SunController>();
        Sequence sequence_sun = DOTween.Sequence();
        Sequence sequence_light = DOTween.Sequence();
        sunController.SunChanger(sequence_sun);
        sunController.AmbientLightChanger(sequence_light);
        sequence_sun.AppendCallback(() =>
             {
                 photoframe.material = newPhoto[index];
                 notes[index].SetActive(true);
                 if (nextDay != null)
                 { nextDay.SetActive(true); }
             });
    }

}
