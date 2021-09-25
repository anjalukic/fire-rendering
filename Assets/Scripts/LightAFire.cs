using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightAFire : MonoBehaviour
{
    public GameObject fieryQuadPrefab;
    public int fireQuadCount = 5;
    // Start is called before the first frame update
    void Start()
    {
        // generate a fire
        Vector3 rotation = new Vector3(0f, 0f, 90f);
        Vector3 pos = new Vector3(0, 0.5f, 0);
        GameObject quad = Instantiate(fieryQuadPrefab, gameObject.transform, false);
        quad.transform.localPosition = pos;
        int billboard = quad.GetComponent<MeshRenderer>().material.GetInt("_Billboard");
        quad.GetComponent<MeshRenderer>().material.SetInt("_Billboard", billboard);
        // if fire isn't a billboard, make a 3D illusion by instantiating multiple fire quads
        rotation.z = 0f;
        if (billboard == 0)
        {
            Debug.Log("billboarding off");
            for (int i = 360/fireQuadCount; i < 360;)
            {
                quad = Instantiate(fieryQuadPrefab, gameObject.transform, false);
                quad.transform.localPosition = pos;
                rotation.y = i;
                quad.transform.Rotate(rotation, Space.Self);
                i += 360/fireQuadCount;
            }
        }
        
    }

   

}
