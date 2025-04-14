extends Resource
class_name NewZone


var name: String = "[unknown]"
var width: float = 0.0
var height: float = 0.0
var difficulty: int = 0

var layers: SerializableArray = SerializableArray.new(
	func() -> NewZoneLayer:
		return NewZoneLayer.new() 
)
