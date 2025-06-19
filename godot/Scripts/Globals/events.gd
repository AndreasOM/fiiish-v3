extends Node

signal game_state_changed( state: Game.State )
signal zone_changed
signal zone_finished
signal settings_changed
signal cheats_changed
signal game_paused

signal zone_edit_enabled
signal zone_edit_disabled
signal zone_test_enabled( filename: String )
signal zone_test_disabled

signal global_message( text: String )
signal achievement_completed( id: String )
signal reward_received( amount: int, icon: Texture, extra: String )
signal queue_toast( toast: Control )

signal kids_mode_changed( enabled: bool )

func broadcast_game_state_changed( state: Game.State ):
	game_state_changed.emit( state )

func broadcast_zone_changed( zone ):
	zone_changed.emit( zone )
	
func broadcast_zone_finished():
	zone_finished.emit()

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

func broadcast_zone_test_enabled( filename: String ):
	zone_test_enabled.emit( filename )

func broadcast_zone_test_disabled( ):
	zone_test_disabled.emit()

func broadcast_global_message( text: String ) -> void:
	self.global_message.emit( text )

func broadcast_achievement_completed( id: String ) -> void:
	self.achievement_completed.emit( id )

func broadcast_reward_received( amount: int, icon: Texture, extra: String ) -> void:
	self.reward_received.emit( amount, icon, extra )
	
func broadcast_queue_toast( toast: Control ) -> void:
	self.queue_toast.emit( toast )
	
func broadcast_kids_mode_changed( enabled: bool ) -> void:
	self.kids_mode_changed.emit( enabled )
