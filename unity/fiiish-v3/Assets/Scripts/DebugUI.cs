using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DebugUI : MonoBehaviour
{
    public Slider zoomSlider = null;
    public Game game = null;

    private GameObject _cameraFrame = null;
    
    // Start is called before the first frame update
    void Start()
    {
        _cameraFrame = transform.Find("CameraFrame").gameObject;

        var debugCameraToggle_go = GameObject.Find("DebugCameraToggle");
        var debugCameraToggle = debugCameraToggle_go.GetComponent<Toggle>();

        debugCameraToggle.SetIsOnWithoutNotify( _cameraFrame.activeSelf );
        
        var zoom = game.GetZoom();
        SetZoom( zoom );
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void SetZoom(float value)
    {
        if (zoomSlider != null)
        {
            zoomSlider.value = value;
        }
    }
    public void OnClickSmallZoomButton()
    {
        SetZoom( 0.25f );
    }
    public void OnClickMediumZoomButton()
    {
        SetZoom( 0.5f );
    }
    public void OnClickNormalZoomButton()
    {
        SetZoom( 1.0f );
    }

    public void OnZoomChanged(float value)
    {
        // Debug.Log("Zoom:" + value);
        if (this.game != null)
        {
            this.game.SetZoom( value );
        }
        if (_cameraFrame != null)
        {
            Debug.Log("Zoom:" + value);
            _cameraFrame.transform.localScale = new Vector3( value, value, value );
        }
    }

    public void OnDebugCameraChanged(Boolean value)
    {
        if (_cameraFrame != null)
        {
            Debug.Log( "OnDebugCameraChanged" + value);
            _cameraFrame.SetActive( value );
        }
    }
}
