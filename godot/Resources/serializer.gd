class_name Serializer

var _data: PackedByteArray
var _pos: int = 0
var _mode: Mode = Mode.Write

enum Mode {
	Read,
	Write,
}

func _init():
	_data = PackedByteArray()
	
func load_file(path: String) -> bool:
	var data = FileAccess.get_file_as_bytes(path)
	self._data = data
	self._pos = 0
	self._mode = Mode.Read
	print("Size of %s = %d" % [ path, self._data.size() ])
	if self._data.size() == 0:
		var e = FileAccess.get_open_error()
		print("Error opening %s" % path )
		return false
	
	return true
	
func save_file(path:String) -> bool:
	
	for i in self._data.size():
		var b = self._data[ i ]
		print("%02x" % b )
		
	var f = FileAccess.open(path, FileAccess.WRITE)
	self._data.resize( self._pos )
	f.store_buffer( self._data )
	
	return true

func ensure_space( c: int ):
	var s = _data.size()
	var p = self._pos
	
	if p+c > s:
		var ns = max(s,1)*2
		print("Resizing serializer to ", ns)
		_data.resize( ns )

func serialize_bool( v: bool ) -> bool:
	var b = 1
	if !v:
		b = 0
	b = self.serialize_u8( b )
	var r = b!=0
	return r
		
func serialize_u8( v: int ) -> int:
	match _mode:
		Mode.Write:
			print("Serializer writing u8")
			ensure_space( 1 )
			self._data.encode_u8( self._pos, v & 0xff )
			self._pos += 1
			return v
		Mode.Read:
			if self._pos + 1 > self._data.size():
				push_warning("Reading past end of data %d/%d" % [ self._pos, self._data.size() ])
				return 0
				
			var r = self._data.decode_u8( self._pos )
			
			self._pos += 1
			return r
		_: # impossible since the above is exhaustive
			return v

func serialize_u16( v: int ) -> int:
	var l = (v>>0) & 0xff
	var h = (v>>8) & 0xff
	
	l = self.serialize_u8( l )
	h = self.serialize_u8( h )
	
	var r = (h<<8) | l
	return r

func serialize_u32( v: int ) -> int:
	var a = (v>> 0) & 0xff
	var b = (v>> 8) & 0xff
	var c = (v>>16) & 0xff
	var d = (v>>24) & 0xff
	
	a = self.serialize_u8( a )
	b = self.serialize_u8( b )
	c = self.serialize_u8( c )
	d = self.serialize_u8( d )
	
	var r = (d<<24)|(c<<16)|(b<<8)|a
	return r

func serialize_f32( v: float ) -> float:
	var bytes = PackedByteArray()
	bytes.resize( 4 )
	
	bytes.encode_float( 0, v )
	
	bytes[ 0 ] = self.serialize_u8( bytes[ 0 ] )
	bytes[ 1 ] = self.serialize_u8( bytes[ 1 ] )
	bytes[ 2 ] = self.serialize_u8( bytes[ 2 ] )
	bytes[ 3 ] = self.serialize_u8( bytes[ 3 ] )

	var r = bytes.decode_float( 0 )	
	return r

func serialize_fixed_string( l: int, v: String ) -> String:
	if self._pos + l >= self._data.size():
		return ""
		
	var bytes = PackedByteArray()
	
	for i in range(l):
		var b = self._data.decode_u8( self._pos + i )
		bytes.push_back( b )
		# bytes[ i ] = b

	var r: String = bytes.get_string_from_utf8()	# :TODO: error handling
	
	self._pos += l	
	return r
