using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : ScriptableObject
{
    private UInt32 _coins = 0;
    private UInt32 _lastDistance = 0;
    private UInt32 _totalDistance = 0;
    private UInt32 _bestDistance = 0;
    private UInt32 _playCount = 0;
    private bool _isMusicEnabled = true;
    private bool _isSoundEnabled = true;
    private bool _isDirty;

    
    public Player()
    {
    }

    public bool TryLoad()
    {
        var serializer = new Serializer();
        var path = GetSavePath();
        Debug.Log($"Player - Loading from ${path}");
        
        if (!serializer.LoadFileSync(path))
        {
            Debug.LogWarning($"Failed to load player from {path}");
            return false;
        }
        

        var player = ScriptableObject.CreateInstance<Player>();
        if (!player.Serialize(ref serializer))
        {
            Debug.LogWarning($"Failed serializing player from {path}");
            return false;
        }
        
        this._isMusicEnabled = player._isMusicEnabled;
        this._isSoundEnabled = player._isSoundEnabled;
        this._coins = player._coins;
        this._lastDistance = player._lastDistance;
        this._totalDistance = player._totalDistance;
        this._bestDistance = player._bestDistance;
        this._playCount = player._playCount;
        this._isDirty = false;
        
        ScriptableObject.DestroyImmediate(player);

        Debug.Log($"Loaded player from {{path}} Music: {this._isMusicEnabled}");
        return true;
    }

    public void Save()
    {
        var serializer = new Serializer();

        if (!Serialize(ref serializer))
        {
            Debug.LogWarning("Serialization failed");
            return;
        }
        
        Debug.Log($"Music: {_isMusicEnabled}");
        Debug.Log("Serialized player");
        
        var path = GetSavePath();
        Debug.Log($"Saving to {path}");
        if (!serializer.SaveFile(path))
        {
            Debug.LogWarning("Failed saving player");
        }
        else
        {
            Debug.Log("Saved player");
            SaveGame.SyncFS();
        }
    }

    private string GetSavePath()
    {
        var path = Application.persistentDataPath;
        if (path.StartsWith("/idbfs/"))
        {
            path = "/idbfs";
        }
        var productPath = "/" + Application.productName;
        if (!path.EndsWith(productPath))
        {
            path = path + productPath;
        }
        path = path + "/player.data";
        
        return path;
    }

    public bool Serialize(ref Serializer serializer)
    {
        byte[] magic = new byte[] { 0x4f, 0x4d, 0x46, 0x49, 0x49, 0x49, 0x53, 0x48 };
        foreach( byte eb in magic ) {
            byte b = eb;
            serializer.Serialize_U8( ref b );
            if( b != eb ) {
                Debug.LogWarning( "Broken Chunk Magic 0x" + b.ToString("X") );
                return false;
            }
        }

        ushort version = 0x0003;
        serializer.Serialize_U16(ref version);
        if (version != 3)
        {
            Debug.LogWarning("Version not supported 0x" + version.ToString("X"));
            return false;
        }

        serializer.Serialize_U32( ref _coins );
        serializer.Serialize_U32( ref _lastDistance );
        serializer.Serialize_U32( ref _totalDistance );
        serializer.Serialize_U32( ref _bestDistance );
        serializer.Serialize_U32( ref _playCount );
        serializer.Serialize_Bool( ref _isMusicEnabled );
        serializer.Serialize_Bool( ref _isSoundEnabled );

        // Debug.Log("Sound after (de)serialize " + _isSoundEnabled.ToString() );
        
        return true;
    }

    public void EnableMusic()
    {
        Debug.Log("EnableMusic");
        if (_isMusicEnabled)
        {
            return;
        }
        _isMusicEnabled = true;
        _isDirty = true;
    }
    public void DisableMusic()
    {
        Debug.Log("DisableMusic");
        if (!_isMusicEnabled)
        {
            return;
        }
        _isMusicEnabled = false;
        _isDirty = true;
    }
    public bool IsMusicEnabled()
    {
        return _isMusicEnabled;
    }
    
    public void EnableSound()
    {
        if (_isSoundEnabled)
        {
            return;
        }
        _isSoundEnabled = true;
        _isDirty = true;
    }
    public void DisableSound()
    {
        if (!_isSoundEnabled)
        {
            return;
        }
        _isSoundEnabled = false;
        _isDirty = true;
    }
    public bool IsSoundEnabled()
    {
        return _isSoundEnabled;
    }

    public void GiveCoins(UInt32 coins)
    {
        _coins += coins;
    }

    public void ApplyDistance(UInt32 distance)
    {
        _totalDistance += distance;
        _bestDistance = Math.Max(_bestDistance, distance);
        _lastDistance = distance;
    }
    public UInt32 Coins()
    {
        return _coins;
    }
    public UInt32 LastDistance()
    {
        return _lastDistance;
    }
    public UInt32 TotalDistance()
    {
        return _totalDistance;
    }
    public UInt32 BestDistance()
    {
        return _bestDistance;
    }
    
}
