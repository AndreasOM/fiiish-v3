class_name HashMap

var _data: Dictionary[ int, Object ] = {}
var _default_key: int = 0
var _default_constructor: Callable = Callable()

func _init( default_key: int, default_constructor: Callable ):
	if default_constructor == null:
		push_warning("HashMap: default_constructor == null")
	if default_constructor.is_null():
		push_warning("HashMap: default_constructor.is_null()")
	_default_key = default_key
	_default_constructor = default_constructor
	
func serialize( s: Serializer ):
	s.serialize_hash_map( self, _default_key, _default_constructor )
	
func size() -> int:
	return _data.size()
	
func keys() -> Array:
	return _data.keys()
	
func erase( key: int ) -> bool:
	return _data.erase( key )

func clear():
	_data.clear()
	
func set_entry(key: int, value: Object) -> bool:
	return _data.set(key, value )
	
func get_entry( key: int, default: Object = null ) -> Object:
	return _data.get( key, default )
	
func get_or_add( key: int, default: Object ) -> Object:
	return _data.get_or_add( key, default )
