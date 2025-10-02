extends Control


func _ready() -> void:
	# Events.game_paused_v1.connect( _on_game_paused )  # OLD SYSTEM - DISABLED
	Events.pause_state_changed.connect( _on_pause_state_changed )
	%FadeableContainer.fade_out( 0.0 )

func _on_pause_state_changed( pause_state: PauseManager.PauseState, reason: PauseManager.PauseReason ) -> void:
	match pause_state:
		PauseManager.PauseState.PAUSED:
			self.visible = true
			self.mouse_filter = Control.MOUSE_FILTER_STOP
			%FadeableContainer.fade_in( 0.3 )
		PauseManager.PauseState.RUNNING:
			# self.visible = false
			self.mouse_filter = Control.MOUSE_FILTER_IGNORE
			%FadeableContainer.fade_out( 0.3 )
		_:
			pass
