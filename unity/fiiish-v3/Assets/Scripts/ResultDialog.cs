using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using Debug = UnityEngine.Debug;

public class ResultDialog : MonoBehaviour
{
    public Game game;
    public ResultRow coinResultRow;
    public ResultRow distanceResultRow;
    public ResultRow bestDistanceResultRow;
    public ResultRow totalDistanceResultRow;
    
    private FadeableUiElement _fadeableUiElement;

    private UInt32 _coinsTarget;
    private float _coinsCurrent;

    private float _coinSpeed = 10.0f;
    
    // Start is called before the first frame update
    IEnumerator Start()
    {
        Setup();
        return Configure();
    }

    void Setup()
    {
        _fadeableUiElement = GetComponent<FadeableUiElement>();
        if (_fadeableUiElement == null)
        {
            Debug.LogWarning($"No FadeableUiElement component found! on ${name}");
        }
    }

    IEnumerator Configure()
    {
        // _fadeableUiElement.FadeOut( 0.0f );
        yield return new WaitForEndOfFrame();
        _fadeableUiElement.FadeOut( 0.0f );
    }
    
    // Update is called once per frame
    void Update()
    {
        if (_coinsCurrent < _coinsTarget)
        {
            _coinsCurrent += Time.deltaTime * _coinSpeed;
            
            var coins = Mathf.FloorToInt(_coinsCurrent);
            coinResultRow.SetTotal($"{coins}");
        }
    }
    public void OnGameStateChanged(Game.State state)
    {
        Debug.Log($"ResultDialog - OnGameStateChanged: {state}");
        switch (state)
        {
            case Game.State.Dying:
                {
                    // :TODO: setup from actual results
                    var gameManager = game.GetGameManager();
                    var coins = gameManager.Coins();
                    var distance = gameManager.CurrentDistanceInMeters();
                    
                    _coinsTarget = (uint)coins;
                    _coinsCurrent = 0.0f;
                    
                    coinResultRow.SetTotal( "0" );
                    coinResultRow.SetCurrent( $"{coins}" );
                    
                    distanceResultRow.SetTotal( $"0 m" );
                    distanceResultRow.SetCurrent( $"{distance} m" );
                    
                    bestDistanceResultRow.SetTotal( $"0 m" );
                    bestDistanceResultRow.SetCurrent( $"" );

                    totalDistanceResultRow.SetTotal( $"0 m" );
                    totalDistanceResultRow.SetCurrent( $"" );
                    
                    _fadeableUiElement.FadeIn( 0.3f );
                }
                break;
            case Game.State.Dead:
                break;
            default:
                {
                    _fadeableUiElement.FadeOut( 0.3f );
                }
                break;
        }
    }
}
