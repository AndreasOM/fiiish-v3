extends Dialog

@onready var achievement_view: AchievementView = %AchievementView


func _ready() -> void:
	if self._dialog_manager != null:
		self.achievement_view.game_manager = self._dialog_manager.game.get_game_manager()
	
	Events.achievement_completed.connect( _on_achievement_completed )
	
func set_dialog_manager( dialog_manager: DialogManager ) -> void:
	super( dialog_manager )
	if self.achievement_view != null:
		self.achievement_view.game_manager = self._dialog_manager.game.get_game_manager()
		
func cancel() -> bool:
	self.close( 0.3 )
	return true

func close( duration: float) -> void:
	fade_out( duration )

func open( duration: float) -> void:
	var game = self._dialog_manager.game
	# :HACK:
	game.sync_achievements_with_player( game.get_player() )
	self.achievement_view.recreate_achievements()
	fade_in( duration )

func fade_out( duration: float ) -> void:
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
	%FadeablePanelContainer.fade_in( duration )

func _on_close_button_pressed() -> void:
	self._dialog_manager.close_dialog(DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3)


func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()

func _on_achievement_completed( id: String ) -> void:
	# :HACK:
	if self._dialog_manager == null:
		return
	var game = self._dialog_manager.game
	game.sync_achievements_with_player( game.get_player() )

func select_achievement( id: String ) -> void:
	self.achievement_view._on_achievement_selected( id )
