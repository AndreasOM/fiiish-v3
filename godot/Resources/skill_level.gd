class_name SkillLevel

var _value: int = 0;

func _init( value: int ):
	_value = value

func get_value() -> int:
	return _value

func set_value( value: int ):
	_value = value
	
func serialize( s: Serializer ):
	_value = s.serialize_u16( _value )
