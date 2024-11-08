using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;


public class ZoneList : MonoBehaviour
{
    public List<string> zones = new List<string>();

    private void Awake()
    {
        Debug.Log("ZoneList - Awake");
    }

    public void SetZones(List<string> zones)
    {
        this.zones = zones;
    }

    public List<string> GetZones()
    {
        return this.zones;
    }
}
