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

    private int _coinsTarget;
    private int _distanceTarget;
    private int _totalDistanceTarget;
    private int _bestDistance;
    
    private EasedInteger _coinsGained;
    private EasedInteger _distanceGained;
    private float _time;
    
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
    
    void Update()
    {
        if (_coinsGained != null)
        {
            _time += Time.deltaTime;
            var coinsGained = _coinsGained.GetForTime(_time);
            if (coinsGained != 0)
            {
                coinResultRow.SetCurrent($"{coinsGained}");
            }
            else
            {
                coinResultRow.SetCurrent("");
            }

            var coins = _coinsTarget - coinsGained;
            coinResultRow.SetTotal($"{coins}");

            var distanceGained = _distanceGained.GetForTime(_time);
            if (distanceGained != 0)
            {
                distanceResultRow.SetCurrent($"{distanceGained} m");
            }
            else
            {
                distanceResultRow.SetCurrent("");
            }

            var distance = _distanceTarget - distanceGained;
            distanceResultRow.SetTotal($"{distance} m");

            var bestDistance = Mathf.Max(distance, _bestDistance);
            bestDistanceResultRow.SetTotal($"{bestDistance} m");

            var totalDistance = _totalDistanceTarget - distanceGained;
            totalDistanceResultRow.SetTotal($"{totalDistance} m");
        }
    }
    public void OnGameStateChanged(Game.State state)
    {
        Debug.Log($"ResultDialog - OnGameStateChanged: {state}");
        switch (state)
        {
            case Game.State.Dying:
                {
                    var gameManager = game.GetGameManager();
                    var coins = gameManager.Coins();
                    var distance = gameManager.CurrentDistanceInMeters();
                    var player = game.GetPlayer();
                    
                    _time = 0.0f;
                    var startTime = 0.0f;
                    var duration = 4.0f*MathF.Log10( Math.Max(coins, distance) )+1.3f;
                    var endTime = startTime + duration;

                    var startCoins = (int)player.Coins();
                    var startDistance = (int)player.TotalDistance();
                    _bestDistance = (int)player.BestDistance();

                    _coinsGained = new EasedInteger(startTime, endTime-0.3f*duration, coins, 0,
                        EasedInteger.EasingFunction.InOutCubic);
                    _coinsTarget = startCoins + coins;

                    _distanceGained = new EasedInteger(startTime+0.3f*duration, endTime, distance, 0,
                        EasedInteger.EasingFunction.InOutCubic);
                    _distanceTarget = distance;
                    _totalDistanceTarget = startDistance + distance;
                    
                    coinResultRow.SetTotal( "" );
                    coinResultRow.SetCurrent( "" );
                    
                    distanceResultRow.SetTotal( "" );
                    distanceResultRow.SetCurrent( "" );
                    
                    bestDistanceResultRow.SetTotal( "" );
                    bestDistanceResultRow.SetCurrent( "" );

                    totalDistanceResultRow.SetTotal( "" );
                    totalDistanceResultRow.SetCurrent( "" );
                    
                    _fadeableUiElement.FadeIn( 0.3f );
                }
                break;
            case Game.State.Dead:
                break;
            default:
                {
                    _coinsGained = null;
                    _fadeableUiElement.FadeOut( 0.3f );
                }
                break;
        }
    }
}
