using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotateCamera : MonoBehaviour
{
    public Transform target;
    public float speedMod = 10;
    // Start is called before the first frame update
    private void Update()
    {
        transform.RotateAround(target.position, new Vector3(0.0f, 1.0f, 0.0f), 20 * Time.deltaTime * speedMod);
    }
}
