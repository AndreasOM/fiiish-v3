class_name Serializer

var _data: PackedByteArray
var _pos: int = 0

func load_file(path: String):
	var data = FileAccess.get_file_as_bytes(path)
	self._data = data
	self._pos = 0
	print("Size of %s = %d" % [ path, self._data.size() ])
	

func serialize_u8( v: int ) -> int:
	if self._pos + 1 >= self._data.size():
		return 0
		
	var r = self._data.decode_u8( self._pos )
	
	self._pos += 1
	return r

func serialize_u16( v: int ) -> int:
	if self._pos + 2 >= self._data.size():
		push_warning("Reading past end of data")
		return 0
		
	var r = self._data.decode_u16( self._pos )
	
	self._pos += 2
	return r

func serialize_u32( v: int ) -> int:
	if self._pos + 4 >= self._data.size():
		return 0
		
	var r = self._data.decode_u32( self._pos )
	
	self._pos += 4
	return r

func serialize_f32( v: float ) -> float:
	if self._pos + 4 >= self._data.size():
		return 0
		
	var r = self._data.decode_float( self._pos )
	
	self._pos += 4
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
