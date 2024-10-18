class_name EasedInteger

enum EasingFunction
{
	LINEAR,
	IN_OUT_CUBIC,
}

var _start_time: float = 0.0
var _end_time: float = 0.0
var _start_value: float = 0.0
var _end_value: float = 0.0
var _easing_function: EasingFunction = EasingFunction.LINEAR

func _init( start_time: float, end_time: float, start_value: int, end_value: int, easing_function: EasingFunction ):
	_start_time = start_time
	_end_time = end_time
	_start_value = start_value
	_end_value = end_value
	_easing_function = easing_function
	
func get_for_time( time: float ) -> int:
	match _easing_function:
		EasingFunction.LINEAR:
			return get_linear_for_time( time )
		EasingFunction.IN_OUT_CUBIC:
			return get_in_out_cubic_for_time( time )
		_:
			return 0
	
func get_linear_for_time( time: float ) -> int:
		var x = clamp( (time - _start_time) / (_end_time - _start_time), 0.0, 1.0 )
		var y = _start_value + (x * (_end_value - _start_value))
		
		return floori( y )
	

func get_in_out_cubic_for_time( time: float ) -> int:
		var x = clamp( (time - _start_time) / (_end_time - _start_time), 0.0, 1.0 )
		var p = 0.0
		if x < 0.5:
			p = 4 * x * x * x
		else:
			p = 1 - pow(-2 * x + 2, 3) / 2
			
		var y = _start_value + (p * (_end_value - _start_value))
		
		return floori( y )
