using System.Runtime.InteropServices;
using UnityEngine;

public class SaveGame
{
    public static void SyncFS()
    {
#if UNITY_WEBGL && !UNITY_EDITOR
        JsSyncDB();
#endif        
    }
#if UNITY_WEBGL && !UNITY_EDITOR
        [DllImport("__Internal")]
        private static extern void JsSyncDB();
#endif
    
}

