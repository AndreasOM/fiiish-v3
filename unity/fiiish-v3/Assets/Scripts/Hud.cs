using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class Hud : MonoBehaviour
{
    public Game game = null;

    private TextMeshProUGUI _coinsValueLabel = null;
    private TextMeshProUGUI _distanceValueLabel = null;

    // Start is called before the first frame update
    void Start()
    {
        Setup();
    }

    void Setup()
    {
        var coinsValueLabelGo = GameObject.Find("CoinsValueText");
        _coinsValueLabel = coinsValueLabelGo.GetComponent<TextMeshProUGUI>();
        var distanceValueLabelGo = GameObject.Find("DistanceValueText");
        _distanceValueLabel = distanceValueLabelGo.GetComponent<TextMeshProUGUI>();
    }

    // Update is called once per frame
    void Update()
    {
        var coins = game.Coins();
        _coinsValueLabel.text = coins.ToString();
        var distance = game.CurrentDistanceInMeters();
        _distanceValueLabel.text = $"{distance} m";
    }
}
