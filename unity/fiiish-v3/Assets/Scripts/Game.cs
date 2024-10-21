using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;

public class Game : MonoBehaviour
{
    public enum State {
        WaitingForStart,
        Swimming,
        Dying,
        Dead,
        Respawning,
    }
    
    public UnityEvent<String> OnZoneChanged;
    public UnityEvent<State> onStateChanged;

    public Camera mainCamera = null;

    private GameManager _gameManager; // = null;
    private MusicManager _musicManager;
    
    private Player _player;
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
        var musicManager = transform.Find("MusicManager");
        var musicManagerGo = musicManager.transform;
        _musicManager = musicManagerGo.GetComponent<MusicManager>();
    }

    void Configure()
    {
        _player = ScriptableObject.CreateInstance<Player>();
        _player.TryLoad();
        _musicManager.FadeOutMusic( 0.0f );
        if (_player.IsMusicEnabled())
        {
            _musicManager.FadeInMusic( 1.5f );
        }
    }
    // Update is called once per frame
    void Update()
    {
        
    }

    public Player GetPlayer()
    {
        return _player;
    }
    public GameManager GetGameManager()
    {
        return _gameManager;
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
    public void OnGameManagerStateChanged(Game.State state)
    {
        onStateChanged?.Invoke(state);

        switch (state)
        {
            case State.Dead:
                CreditLastSwim();
                break;
            default:
                break;
        }
    }
    
    private void CreditLastSwim()
    {
        var coins = (UInt32)_gameManager.TakeCoins();
        _player.GiveCoins(coins);
        
        var distance = (UInt32)_gameManager.TakeCurrentDistanceInMeters();
        _player.ApplyDistance(distance);
        
        _player.Save();
    }

    public void EnableMusic()
    {
        _player.EnableMusic();
        _player.Save();
        _musicManager.FadeInMusic( 0.5f );
    }
    
    public void DisableMusic()
    {
        _player.DisableMusic();
        _player.Save();
        _musicManager.FadeOutMusic( 0.5f );
    }
    public void EnableSound()
    {
        _player.EnableSound();
        _player.Save();
    }
    public void DisableSound()
    {
        _player.DisableSound();
        _player.Save();
    }
}
