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
    
    private List<byte> _buffer = new List<byte>();

    private Mode _mode = Mode.Write;
    enum Mode
    {
        Read,
        Write,
    }
    
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
            this._mode = Mode.Read;
            return true;
        }
        return false;
    }

    public bool SaveFile(string path)
    {
        using (FileStream fs = File.OpenWrite(path))
        {
            foreach (var b in _buffer)
            {
                fs.WriteByte(b);
            }
        }
        return true;
    }

    private byte ReadNextByte()
    {
        // if( m_data == null ) { return 0x00; }
        if (m_pos >= m_length)
        {
            //Debug.LogWarning( $"Couldn't read byte ${m_pos} of ${m_length}" );
            return 0x00;
        }

        //Debug.Log( m_data[ m_pos ].ToString("X"));

        return m_data[ m_pos++ ];
    }

    private void WriteNextByte(byte value)
    {
        _buffer.Add(value);
    }
    public void Serialize_Bool( ref bool value )
    {
        switch (this._mode)
        {
            case Mode.Write:
                WriteNextByte( (byte)(value?1:0) );
                break;
            case Mode.Read:
                var b = ReadNextByte();
                // Debug.Log($"Read: ${b}");
                value = b == 1;
                break;
        }
    }
    
    public void Serialize_U8( ref byte value )
    {
        switch (this._mode)
        {
            case Mode.Write:
                WriteNextByte( value );
                break;
            case Mode.Read:
                value = ReadNextByte();
                break;
        }
    }

    public void Serialize_U16( ref ushort value )
    {
        switch (this._mode)
        {
            case Mode.Write:
                {
                    byte l = (byte)(value & 0xFF);
                    byte h = (byte)(value >> 8);

                    WriteNextByte(l);
                    WriteNextByte(h);
                }
                break;
            case Mode.Read:
                {
                    ushort l = ReadNextByte();
                    ushort h = ReadNextByte();

                    value = (ushort)(h << 8 | l);
                }
                break;
        }
    }

    public void Serialize_U32( ref uint value )
    {
        switch (this._mode)
        {
            case Mode.Write:
                {
                    byte a = (byte)(value & 0xFF);
                    byte b = (byte)(value >> 8);
                    byte c = (byte)(value >> 16);
                    byte d = (byte)(value >> 24);

                    WriteNextByte(a);
                    WriteNextByte(b);
                    WriteNextByte(c);
                    WriteNextByte(d);
                }
                break;
            case Mode.Read:
                {
                    uint a = ReadNextByte();
                    uint b = ReadNextByte();
                    uint c = ReadNextByte();
                    uint d = ReadNextByte();

                    value = (uint)(d << 24 | c << 16 | b << 8 | a);
                }
                break;
        }
    }

    public void Serialize_F32( ref float value )
    {
        switch (this._mode)
        {
            case Mode.Write:
                Debug.LogError("Serialize_F32 not implemented yet");
                break;
            case Mode.Read:
                uint v = BitConverter.ToUInt32(BitConverter.GetBytes( value ), 0);
                Serialize_U32( ref v );
                //Debug.Log( String.Format( "Float? 0x{0}", v.ToString("X") ));
                value = BitConverter.ToSingle(BitConverter.GetBytes( v ), 0);
                break;
        }
    }

    public void Serialize_FixedString( ref string value, ushort length )
    {
        switch (this._mode)
        {
            case Mode.Write:
                Debug.LogError("Serialize_FixedString not implemented yet");
                break;
            case Mode.Read:
                var data = new byte[ length ];
                var first_zero = (int)length;

                for( int i = 0; i<length; ++i )
                {
                    data[ i ] = ReadNextByte();
                    if( data[ i ] == 0 && first_zero >= length ) {
                        first_zero = i;
                    }
                }
                value = System.Text.Encoding.UTF8.GetString(data, 0, first_zero);
                break;
        }
    }
}
