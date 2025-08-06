extends Node

func _ready() -> void:
	var r = Steam.steamInitEx()
	
func get_steam() -> Variant:
	return Steam
