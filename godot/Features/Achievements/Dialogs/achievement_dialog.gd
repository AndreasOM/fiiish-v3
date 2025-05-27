extends Dialog

@onready var achievement_view: AchievementView = %AchievementView


func _ready() -> void:
	if self._dialog_manager != null:
		self.achievement_view.game_manager = self._dialog_manager.game.get_game_manager()
	
func set_dialog_manager( dialog_manager: DialogManager ):
	super( dialog_manager )
	if self.achievement_view != null:
		self.achievement_view.game_manager = self._dialog_manager.game.get_game_manager()
		
func close( duration: float):
	fade_out( duration )

func open( duration: float):
	self.achievement_view.recreate_achievements()
	fade_in( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
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
