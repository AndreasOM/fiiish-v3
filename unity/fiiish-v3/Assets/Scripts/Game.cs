using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Game : MonoBehaviour
{
    private Camera _camera = null;
    // Start is called before the first frame update
    void Start()
    {
        var camera_go = GameObject.FindWithTag("MainCamera");
        _camera = camera_go.GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SetZoom(float value)
    {
        _camera.gameObject.transform.localScale = new Vector3(value, value, value);
    }

    public float GetZoom()
    {
        return _camera.gameObject.transform.localScale.x;
    }
}
