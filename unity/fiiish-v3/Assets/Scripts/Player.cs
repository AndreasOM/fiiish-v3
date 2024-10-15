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
        Debug.Log($"Loading from ${path}");
        
        if (!serializer.LoadFile(path))
        {
            Debug.LogWarning($"Failed to load player from ${path}");
            return false;
        }

        var player = ScriptableObject.CreateInstance<Player>();
        if (!player.Serialize(ref serializer))
        {
            Debug.LogWarning($"Failed serializing player from ${path}");
            return false;
        }
        
        this._isMusicEnabled = player._isMusicEnabled;
        this._isSoundEnabled = player._isSoundEnabled;
        this._isDirty = false;
        
        ScriptableObject.DestroyImmediate(player);

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
        
        Debug.Log("Serialized player");
        
        var path = GetSavePath();
        Debug.Log($"Saving to ${path}");
        serializer.SaveFile(path);
    }

    private string GetSavePath()
    {
        var path = Application.persistentDataPath + "/player.data";
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

}
