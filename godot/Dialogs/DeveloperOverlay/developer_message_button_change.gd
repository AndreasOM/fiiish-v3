class_name DeveloperMessageButtonChange
extends DeveloperMessage

var name: String = ""
var pressed: bool = false

func _init( i_name: String, i_pressed: bool ) -> void:
	self.name = i_name
	self.pressed = i_pressed

func _to_string() -> String:
	return "DeveloperMessageButtonChange %s -> %d" % [ self.name, int( self.pressed ) ]
