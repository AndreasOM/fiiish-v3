using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Game : MonoBehaviour
{
    public UnityEvent<String> OnZoneChanged;
    
    private Camera _camera = null;

    private GameManager _gameManager; // = null;
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        var camera_go = GameObject.FindWithTag("MainCamera");
        _camera = camera_go.GetComponent<Camera>();
        var gameManager = transform.Find("GameManager");
        var gameManagerGo = gameManager.transform;
        _gameManager = gameManagerGo.GetComponent<GameManager>();
    }

    void Configure()
    {
        
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
    public void HandleOnZoneChanged(String zoneName)
    {
        OnZoneChanged.Invoke(zoneName);
    }

    public float GetZoneProgress()
    {
        return _gameManager.GetZoneProgress();
    }

    public void GotoNextZone()
    {
        _gameManager.GotoNextZone();
    }

}
