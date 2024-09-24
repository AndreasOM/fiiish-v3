using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class DebugUI : MonoBehaviour
{
    public Game game = null;

    public Slider zoomSlider = null;
    public UIProgressBar zoneProgressBar;

    private GameObject _cameraFrame = null;
    private TextMeshProUGUI _zoneNameLabel = null;
    private TextMeshProUGUI _coinsValueLabel = null;
    
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        _cameraFrame = transform.Find("CameraFrame").gameObject;
        var zoneNameLabelGo = GameObject.Find("ZoneNameLabel");
        _zoneNameLabel = zoneNameLabelGo.GetComponent<TextMeshProUGUI>();
        var coinsValueLabelGo = GameObject.Find("CoinsValueLabel");
        _coinsValueLabel = coinsValueLabelGo.GetComponent<TextMeshProUGUI>();
    }

    void Configure()
    {
        var debugCameraToggle_go = GameObject.Find("DebugCameraToggle");
        var debugCameraToggle = debugCameraToggle_go.GetComponent<Toggle>();
        debugCameraToggle.SetIsOnWithoutNotify( _cameraFrame.activeSelf );
        
        var zoom = game.GetZoom();
        SetZoom( zoom );

        _zoneNameLabel.text = "From Script";
    }
    // Update is called once per frame
    void Update()
    {
        var progress = game.GetZoneProgress();
        zoneProgressBar.SetProgress( progress );
        var coins = game.Coins();
        _coinsValueLabel.text = coins.ToString();
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

    public void OnClickNextZoneButton()
    {
        Debug.Log( "OnClickNextZoneButton" );
        this.game.GotoNextZone();
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

    public void OnZoneChanged(String zoneName)
    {
        Debug.Log("Zone Changed to " + zoneName);
        _zoneNameLabel.text = zoneName;
    }
}
