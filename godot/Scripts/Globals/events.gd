extends Node

signal state_changed
signal zone_changed
signal settings_changed


func broadcast_state_changed( state: Game.State ):
	state_changed.emit( state )
	
func broadcast_zone_changed( zone ):
	zone_changed.emit( zone )
	
func broadcast_settings_changed( ):
	settings_changed.emit()
