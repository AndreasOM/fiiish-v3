class_name LeaderboardDialog
extends FiiishDialog

@onready var shop_frame_title_container: ShopFrameTitleContainer = %ShopFrameTitleContainer
@onready var coins_texture_button: TextureButton = %CoinsTextureButton

func cancel() -> bool:
	self.close( 0.3 )
	return true

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
	super.open( duration )
	if self.coins_texture_button != null:
		self.coins_texture_button.grab_focus.call_deferred()

func _on_close_button_pressed() -> void:
	self.close( 0.3 )

func _on_coins_texture_button_pressed() -> void:
#	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_COINS )
	pass

func _on_distance_texture_button_pressed() -> void:
#	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_DISTANCE )
	pass

func _on_coins_texture_button_focus_entered() -> void:
	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_COINS )

func _on_distance_texture_button_focus_entered() -> void:
	self._switch_to_leaderboard( LeaderboardTypes.Type.LOCAL_DISTANCE )
