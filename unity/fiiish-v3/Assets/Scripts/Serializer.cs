using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System;
using System.IO;
using System.Text;

public class Serializer // : ScriptableObject
{
    private int m_length = 0;
    private int m_pos = 0;
    private byte[] m_data = null;

    public bool LoadFile( string path )
    {

        using (FileStream fs = File.OpenRead(path))
        {
            var l = (int)fs.Length;
            Debug.Log( "Length: " + l);
            var data = new byte[ l ];
            var n = fs.Read(data, 0, l);
            if( n != l ) {
                Debug.LogWarning( "Couldn't read full file");
                return false;
            }
            /*
            for( int i=0; i<10; ++i){
                Debug.Log( data[ i ].ToString("X"));
            }
            */

            this.m_data = data;
            this.m_pos = 0;
            this.m_length = l;

            return true;
        }


        return false;
    }

    private byte next_byte()
    {
        // if( m_data == null ) { return 0x00; }
        if( m_pos+1 >= m_length ) { return 0x00; }

        //Debug.Log( m_data[ m_pos ].ToString("X"));

        return m_data[ m_pos++ ];
    }

    public void Serialize_U8( ref byte value )
    {
        value = next_byte();
    }

    public void Serialize_U16( ref ushort value )
    {
        ushort l = next_byte();
        ushort h = next_byte();

        value = (ushort)(h << 8 | l);
    }

    public void Serialize_U32( ref uint value )
    {
        uint a = next_byte();
        uint b = next_byte();
        uint c = next_byte();
        uint d = next_byte();

        value = (uint)( d << 24 | c << 16 | b << 8 | a );
    }

    public void Serialize_F32( ref float value )
    {
        uint v = BitConverter.ToUInt32(BitConverter.GetBytes( value ), 0);
        Serialize_U32( ref v );
        //Debug.Log( String.Format( "Float? 0x{0}", v.ToString("X") ));
        value = BitConverter.ToSingle(BitConverter.GetBytes( v ), 0);
    }

    public void Serialize_FixedString( ref string value, ushort length )
    {
        var data = new byte[ length ];
        var first_zero = (int)length;

        for( int i = 0; i<length; ++i )
        {
            data[ i ] = next_byte();
            if( data[ i ] == 0 && first_zero >= length ) {
                first_zero = i;
            }
        }
        value = System.Text.Encoding.UTF8.GetString(data, 0, first_zero);
    }
}
