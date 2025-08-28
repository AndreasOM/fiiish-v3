extends Node

var _initial_response: Dictionary = {}
func _ready() -> void:
	self._initial_response = Steam.steamInitEx()
	
func get_initial_response() -> Dictionary:
	return self._initial_response

func get_steam() -> Variant:
	return Steam
