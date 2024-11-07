using System.Collections.Generic;
using UnityEngine;


public class ZoneList : MonoBehaviour
{
    public List<string> zones = new List<string>();
    
    public void SetZones(List<string> zones)
    {
        this.zones = zones;
    }

    public List<string> GetZones()
    {
        return this.zones;
    }
}
