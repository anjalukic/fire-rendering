using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightAFire : MonoBehaviour
{
    public GameObject fieryQuadPrefab;
    public GameObject logPrefab;
    public bool billboard = true;
    public int fireQuadCount = 5;
    // Start is called before the first frame update
    void Start()
    {
        // generate a wood pile
        GameObject log;
        Vector3 rotation = new Vector3(0f, 0f, 90f);
        for (int i = 0; i<360;)
        {
            log = Instantiate(logPrefab, new Vector3(0, 0, 0), Quaternion.identity);
            rotation.y = i;
            log.transform.Rotate(rotation, Space.Self);
            i += 360 / 4;
        }
        // generate a fire
        Vector3 pos = new Vector3(0, 0.5f, 0);
        GameObject quad = Instantiate(fieryQuadPrefab, new Vector3(0, 0, 0), Quaternion.identity);
        quad.transform.position = pos;
        quad.GetComponent<MeshRenderer>().material.SetInt("_Billboard", billboard ? 1 : 0);
        // if fire isn't a billboard, make a 3D illusion by instantiating multiple fire quads
        rotation.z = 0f;
        if (!billboard)
        {
            for (int i = 360/fireQuadCount; i < 360;)
            {
                quad = Instantiate(fieryQuadPrefab, new Vector3(0, 0, 0), Quaternion.identity);
                quad.transform.position = pos;
                rotation.y = i;
                quad.transform.Rotate(rotation, Space.Self);
                i += 360/fireQuadCount;
            }
        }
        
    }

   

}
