using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum PickupEffect
{
    Magnet,
    Rain,
    Explosion,
    None
}
public class Pickup : MonoBehaviour
{
    public PickupEffect effect = PickupEffect.None;
    public int coinValue = 1;
    public AudioEffectId collectAudioEffect = AudioEffectId.None;
    
    private bool _alive = true;

    public PickupEffect Effect()
    {
        return effect;
    }

    public int CoinValue()
    {
        return coinValue;
    }

    public AudioEffectId CollectAudioEffect()
    {
        return collectAudioEffect;
    }
    public void Collect()
    {
        _alive = false;
    }

    public bool IsAlive()
    {
        return _alive;
    }
}
