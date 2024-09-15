using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System;

public class NewZoneLayerObject {
    private ushort m_id = 0xffff;
    private uint   m_crc = 0xdeadbeef;
    private float  m_pos_x = 0.0f;
    private float  m_pos_y = 0.0f;
    private float  m_rotation = 0.0f;

    public float PosX()
    {
        return m_pos_x;
    }
    public float PosY()
    {
        return m_pos_y;
    }
    public float Rotation()
    {
        return m_rotation;
    }

    public uint Crc()
    {
        return m_crc;
    }
    public bool Serialize( ref Serializer serializer )
    {
        serializer.Serialize_U16( ref m_id );
        serializer.Serialize_U32( ref m_crc );
        serializer.Serialize_F32( ref m_pos_x );
        serializer.Serialize_F32( ref m_pos_y );
        serializer.Serialize_F32( ref m_rotation );
        // Debug.Log( String.Format("\t\tObj: '{0}'  @{1},{2} rot {3} [{4}", m_id, m_pos_x, m_pos_y, m_rotation, m_crc.ToString("X") ) );

        return true;
    }
}

public class NewZoneLayer {
    private string m_name = "";
    private List<NewZoneLayerObject> m_objects = new List<NewZoneLayerObject>();

    public string Name()
    {
        return m_name;
    }

    public List<NewZoneLayerObject> Objects()
    {
        return m_objects;
    }

    public bool Serialize( ref Serializer serializer )
    {
        serializer.Serialize_FixedString( ref m_name, 16 );
        Debug.Log( String.Format("\tLayer Name: '{0}'", m_name ) );

        ushort object_count = 0;
        serializer.Serialize_U16( ref object_count );
        for( int o = 0; o<object_count; ++o ){
            var obj = new NewZoneLayerObject();
            obj.Serialize( ref serializer );
            m_objects.Add( obj );
        }

        return true;
    }
}

public class NewZone : ScriptableObject
{
    private Vector2 _size;
    private List<NewZoneLayer> m_layers = new List<NewZoneLayer>();

    public Vector2 GetSize()
    {
        return _size;
    }
    
    public List<NewZoneLayer> Layers()
    {
        return m_layers;
    }

    public bool Serialize( ref Serializer serializer )
    {
        ushort magic = 0x4f53;
        serializer.Serialize_U16( ref magic );

        const ushort expected_magic = 0x4f53;
        if( magic != expected_magic ) { 
            Debug.LogWarning( "Broken magic 0x" + magic.ToString("X") );
            return false;
        }

        ushort version = 0x0001;
        serializer.Serialize_U16( ref version );
        if( version != 1 ) {
            Debug.LogWarning( "Version not supported 0x" + version.ToString("X") );
            return false;
        }

        byte[] expected_chunk_magic = new byte[] { 0x46, 0x49, 0x53, 0x48, 0x4e, 0x5a, 0x4e };

        foreach( byte eb in expected_chunk_magic ) {
            byte b = eb;
            serializer.Serialize_U8( ref b );
            if( b != eb ) {
                Debug.LogWarning( "Broken Chunk Magic 0x" + b.ToString("X") );
                return false;
            }
        }

        byte flags = (byte)'E'; // 0x45
        serializer.Serialize_U8( ref flags );
        if( flags != (byte)'E' ) {
            Debug.LogWarning( "Compression/flags '[:TODO:]' not supported." );
            return false;
        }

        uint chunk_version = 2;
        serializer.Serialize_U32( ref chunk_version );
        if( chunk_version != 2 ) {
            Debug.LogWarning( "Version not supported 0x" + chunk_version.ToString("X") );
            return false;
        }

        string name = "";
        serializer.Serialize_FixedString( ref name, 64 );
        this.name = name;

        ushort difficulty = 0;
        serializer.Serialize_U16( ref difficulty );

        float size_x = 12.34f;
        serializer.Serialize_F32( ref size_x );
        float size_y = 0.0f;
        serializer.Serialize_F32( ref size_y );

        this._size.x = size_x;
        this._size.y = size_y;
        Debug.Log( String.Format("Name: '{0}'  Difficulty {1}, Size {2}x{3}", name, difficulty, size_x, size_y ) );

        ushort layer_count = 0;
        serializer.Serialize_U16( ref layer_count );
        for( int l = 0; l<layer_count; ++l ){
            var layer = new NewZoneLayer();
            layer.Serialize( ref serializer );
            m_layers.Add( layer );
        }

        return true;
    }
}
