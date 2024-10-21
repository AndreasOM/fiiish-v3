using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Background : MonoBehaviour
{
    public Game game = null;
    
    public float Phase = 0.5f;
    public float Offset = 0.0f;
    
    private Material _material = null;

    private float _minPhase = 0.0f;
    private float _maxPhase = 0.0f;

    // Start is called before the first frame update

    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        var ri = GetComponent<RawImage>();
        if (ri == null)
        {
            Debug.LogWarning("No raw image attached to Background");
            return;
        }

        if (ri.material == null)
        {
            Debug.LogWarning("No material attached to Background");
            return;
        }
        _material = ri.material;
    }

    void Configure()
    {
        Phase = 0.0f;
        Offset = 0.0f;
    }

    public void OnGameStateChanged(Game.State state)
    {
        switch (state)
        {
            case Game.State.WaitingForStart:
                // (16.0 / 128.0, 96.0 / 128.0)
                Phase = 0.0f;
                _minPhase = 16.0f / 128.0f;
                _maxPhase = 96.0f / 128.0f;
                break;
            case Game.State.Swimming:
                // (16.0 / 128.0, 96.0 / 128.0)
                _minPhase = 16.0f / 128.0f;
                _maxPhase = 96.0f / 128.0f;
                break;
            case Game.State.Dying:
                // (112.0 / 128.0, 112.0 / 128.0)
                _minPhase = 112.0f / 128.0f;
                _maxPhase = 112.0f / 128.0f;
                break;
            case Game.State.Dead:
                // (112.0 / 128.0, 112.0 / 128.0)
                _minPhase = 112.0f / 128.0f;
                _maxPhase = 112.0f / 128.0f;
                break;
            case Game.State.Respawning:
                // (127.0 / 128.0, 127.0 / 128.0)
                _minPhase = 127.0f / 128.0f;
                _maxPhase = 127.0f / 128.0f;
                break;
        }
    }
    // Update is called once per frame
    void Update()
    {
        Offset += 0.5f * (1.0f / 1024.0f) * game.GetGameManager().CurrentSpeed() * Time.deltaTime;
        
        switch (Offset)
        {
            case > 1.0f:
                Offset -= 1.0f;
                break;
            case < -1.0f:
                Offset += 1.0f;
                break;
        }

        var delta = _maxPhase - _minPhase;

        var targetPhase = (0.5f + 0.5f * Mathf.Sin(0.5f * Time.time)) * delta + _minPhase;
        
        Phase = Mathf.Lerp(Phase, targetPhase, 0.01f);
        if( _material != null )
        {
            _material.SetFloat("_Phase", Phase);
            _material.SetFloat("_Offset", Offset);
        }
    }
}
