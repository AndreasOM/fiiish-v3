class_name DeveloperMessageButtonChange
extends DeveloperMessage

var name: String = ""
var pressed: bool = false

func _init( name: String, pressed: bool ) -> void:
	self.name = name
	self.pressed = pressed

func _to_string() -> String:
	return "DeveloperMessageButtonChange %s -> %d" % [ self.name, int( self.pressed ) ]
