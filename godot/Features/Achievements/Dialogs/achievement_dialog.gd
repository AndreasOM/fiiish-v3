class_name AchievementDialog
extends FiiishDialog

@onready var achievement_view: AchievementView = %AchievementView


func _ready() -> void:
	super._ready()
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

func confirm() -> bool:
	self.achievement_view.collect_selected_achievement()
	return true
	
func open( duration: float) -> void:
	var game = self._dialog_manager.game
	# :HACK:
	game.sync_achievements_with_player( game.get_player() )
	self.achievement_view.recreate_achievements()
	self.achievement_view.grab_focus_for_achievement()
	super.open( duration )

func _on_close_button_pressed() -> void:
	self.close( 0.3 )

func _on_achievement_completed( id: String ) -> void:
	# :HACK:
	if self._dialog_manager == null:
		return
	var game = self._dialog_manager.game
	game.sync_achievements_with_player( game.get_player() )

func select_achievement( id: String ) -> void:
	self.achievement_view._on_achievement_selected( id )
