using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FixedAspect : MonoBehaviour
{
    public float Aspect = 1920.0f / 1080.0f;
    public Camera mainCamera = null;
    
    private RawImage _rawImage = null;
    
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        _rawImage = GetComponent<RawImage>();
    }

    void Configure()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var camAspect = mainCamera.aspect;
        Debug.Log($"{camAspect}");
        _rawImage.uvRect = new Rect(0, 0, camAspect / Aspect, 1.0f );
    }
}
