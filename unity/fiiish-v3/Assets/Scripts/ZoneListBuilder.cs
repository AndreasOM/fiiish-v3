#if UNITY_EDITOR
using UnityEngine;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using System.Collections.Generic;
using System.IO;

public class ZoneListBuilder : MonoBehaviour , IPreprocessBuildWithReport
{
    public int callbackOrder { get { return 0; } }
    public void OnPreprocessBuild(BuildReport report)
    {
        Debug.Log("ZoneListBuilder.OnPreprocessBuild for target " + report.summary.platform + " at path " + report.summary.outputPath);
        var zone_path = Application.streamingAssetsPath + "/Zones/";
        var zone_pattern = "*.nzne";
        var zone_files = Directory.GetFiles(zone_path, zone_pattern);
        List<string> zones = new List<string>();
        // zones.Clear();
        foreach (var zone_file in zone_files)
        {
            var zone_name = Path.GetFileName(zone_file);
            zones.Add( zone_name );
        }
        
        Debug.Log($"Added {zones.Count} zones to list");

        var zoneLists = FindObjectsByType<ZoneList>(FindObjectsSortMode.None);
        foreach (var zlo in zoneLists)
        {
            var zl = zlo.GetComponent<ZoneList>();
            if (zl != null)
            {
                zl.SetZones( zones );
            }
        }
    }
    
}
#endif