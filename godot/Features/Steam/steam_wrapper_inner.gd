extends Node

var _initial_response: Dictionary = {
	"status": -1,
	"verbal": "uninitialised",
}

func _ready() -> void:
	var app_id = ProjectSettings.get("steam/initialization/app_id")
	self._initial_response = Steam.steamInitEx( app_id, true )
	
func get_initial_response() -> Dictionary:
	return self._initial_response

func get_steam() -> Variant:
	return Steam
