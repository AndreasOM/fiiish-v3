extends Dialog
class_name LeaderboardDialog

@onready var shop_frame_title_container: ShopFrameTitleContainer = %ShopFrameTitleContainer

func close( duration: float) -> void:
	fade_out( duration )

func _format_distance( distance: int ) -> String:
	return "%d m" % distance
	
func _switch_to_leaderboard( type: LeaderboardTypes.Type ) -> void:
	var leaderboard = Leaderboard.new("dummy")
	
	var game = self._dialog_manager.game
	if game != null:
		var player = game.get_player()
		if player != null:
			var l = player.get_leaderboard( type )
			if l != null:
				leaderboard = l
				
	var score_formatter = Callable()
	match type:
		LeaderboardTypes.Type.LOCAL_DISTANCE:
			score_formatter = _format_distance
		_:
			pass
				
	%LeaderBoardElement.set_leaderboard( leaderboard, score_formatter )
	# %TitleLabel.text = "Leaderboard - %s" % leaderboard.name()
	self.shop_frame_title_container.title = "Leaderboard - %s" % leaderboard.name()
	
	
func open( duration: float) -> void:
	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_COINS )
	fade_in( duration )

func fade_out( duration: float ) -> void:
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
	%FadeablePanelContainer.fade_in( duration )

func _on_close_button_pressed() -> void:
	# print( "Leaderboard Close")
	self._dialog_manager.close_dialog(DialogIds.Id.LEADERBOARD_DIALOG, 0.3)


func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()

func _on_coins_texture_button_pressed() -> void:
	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_COINS )

func _on_distance_texture_button_pressed() -> void:
	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_DISTANCE )
