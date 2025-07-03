extends Control


func _ready() -> void:
	Events.game_paused.connect( _on_game_paused )
	%FadeableContainer.fade_out( 0.0 )

func _on_game_paused( is_paused: bool ) -> void:
	if is_paused:
		self.visible = true
		%FadeableContainer.fade_in( 0.3 )
	else:
		# self.visible = false
		%FadeableContainer.fade_out( 0.3 )
