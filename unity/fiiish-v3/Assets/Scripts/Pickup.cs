using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum PickupEffect
{
    Magnet,
    None
}
public class Pickup : MonoBehaviour
{
    public PickupEffect effect = PickupEffect.None;
    
    private bool _alive = true;

    public PickupEffect Effect()
    {
        return effect;
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
