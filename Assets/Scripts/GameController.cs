using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class DayMaster
{
    public List<GameObject> choices = new List<GameObject>();
    public bool unlocked = false;
    public EventMaster eventMaster;
}

public class GameController : MonoBehaviour
{
    public List<DayMaster> days = new List<DayMaster>();

    public int currentDay = 0;
    void Update()
    {
        for (int i = 0; i < 2; i++)
        {
            if (days[currentDay].choices[i].name == SelectDetection())
            {
                days[currentDay].eventMaster.index = i;
                days[currentDay].eventMaster.gameObject.SetActive(true);
                days[currentDay].unlocked = true;
            }
        }

        if (days[currentDay].unlocked && currentDay < 2)
        {
            currentDay++;
        }
    }
    public string SelectDetection()
    {
        if (Input.GetMouseButtonDown(0))
        {
            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                for (int i = 0; i < 2; i++)
                {
                    MeshCollider mesh = days[currentDay].choices[i].GetComponent<MeshCollider>();
                    Destroy(mesh);
                }

                Instantiate(Resources.Load<GameObject>("SelectedCircle"), hit.collider.gameObject.transform.position, hit.collider.gameObject.transform.rotation);
                return hit.collider.gameObject.name;
            }
        }
        return null;
    }
}
