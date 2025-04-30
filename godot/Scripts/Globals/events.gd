extends Node

signal state_changed
signal zone_changed
signal settings_changed
signal cheats_changed
signal game_paused

signal zone_edit_enabled
signal zone_edit_disabled


func broadcast_state_changed( state: Game.State ):
	state_changed.emit( state )
	
func broadcast_zone_changed( zone ):
	zone_changed.emit( zone )
	
func broadcast_settings_changed( ):
	settings_changed.emit()

func broadcast_cheats_changed( ):
	cheats_changed.emit()

func broadcast_game_paused( is_paused: bool ):
	game_paused.emit( is_paused )

func broadcast_zone_edit_enabled( ):
	zone_edit_enabled.emit()

func broadcast_zone_edit_disabled( ):
	zone_edit_disabled.emit()
