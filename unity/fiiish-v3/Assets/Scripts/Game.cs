using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;

public class Game : MonoBehaviour
{
    public UnityEvent<String> OnZoneChanged;
    
    public Camera mainCamera = null;

    private GameManager _gameManager; // = null;
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        /*
        var camera_go = GameObject.FindWithTag("MainCamera");
        if (camera_go == null)
        {
            Debug.LogError("MainCamera not found");
        }
        _camera = camera_go.GetComponent<Camera>();
        */
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
        mainCamera.gameObject.transform.localScale = new Vector3(value, value, value);
    }

    public float GetZoom()
    {
        return mainCamera.gameObject.transform.localScale.x;
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

    public int Coins()
    {
        return _gameManager.Coins();
    }

    public int CurrentDistanceInMeters()
    {
        return _gameManager.CurrentDistanceInMeters();
    }

    public bool TogglePause()
    {
        var paused = _gameManager.TogglePause();
        // gameObject.enabled = !paused;
        // gameObject.SetActive( !paused );
        return paused;
    }

    public bool IsPaused()
    {
        return _gameManager.IsPaused();
    }

}
