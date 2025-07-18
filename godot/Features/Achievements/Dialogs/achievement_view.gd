extends Control
class_name AchievementView

@onready var achievement_container: GridContainer = %AchievementContainer
@onready var achievement_element_view: AchievementElementView = %AchievementElementView

@export var game_manager: GameManager = null

var _element = preload("res://Features/Achievements/achievement_element.tscn")
var _button_element = preload("res://Features/Achievements/Dialogs/achievement_button.tscn")
var _selected_achievement_id: String = ""

func recreate_achievements() -> void:
	var achievement_config_manager = self.game_manager.get_achievement_config_manager()
	var achievement_manager = self.game_manager.get_achievement_manager()
	
	for c in self.achievement_container.get_children():
		c.get_parent().remove_child( c )
		c.queue_free()
	
	var keys = achievement_config_manager.get_keys()
	
	if self._selected_achievement_id.is_empty():
		if !keys.is_empty():
			self._on_achievement_selected( keys[ 0 ] )
			
	for id in keys:
		var ac = achievement_config_manager.get_config( id )
		if ac == null:
			continue
		
		var s = achievement_manager.get_achievement_state( id )
		if ac.hidden:
			match s:
				AchievementStates.State.UNKNOWN:
					continue
				_:
					pass
		var ab = self._button_element.instantiate() as AchievementButton
		if ab == null:
			continue
		ab.config = ac
		ab.state = s
		ab.selected = id == self._selected_achievement_id
		ab.pressed.connect( _on_achievement_selected )
		self.achievement_container.add_child( ab )
	
func update_achievements() -> void:
	var achievement_config_manager = self.game_manager.get_achievement_config_manager()
	var achievement_manager = self.game_manager.get_achievement_manager()
	
	for c in self.achievement_container.get_children():
		var ab = c as AchievementButton
		if ab == null:
			continue
		var id = ab.config.id
		var s = achievement_manager.get_achievement_state( id )
		ab.state = s
		ab.selected = id == self._selected_achievement_id

func _update_selection() -> void:
	for c in self.achievement_container.get_children():
		var ab = c as AchievementButton
		if ab == null:
			continue
		var id = ab.config.id
		ab.selected = id == self._selected_achievement_id
	
func _on_achievement_selected( id: String ) -> void:
	var achievement_config_manager = self.game_manager.get_achievement_config_manager()
	var achievement_manager = self.game_manager.get_achievement_manager()
	var ac = achievement_config_manager.get_config( id )
	var s = achievement_manager.get_achievement_state( id )

	self.achievement_element_view.config = ac
	self.achievement_element_view.state = s
	self._selected_achievement_id = id
	self._update_selection()

func _on_achievement_element_view_collect_pressed(id: String) -> void:
	if !self.game_manager.collect_achievement( id ):
		return
	self.update_achievements()
	var achievement_manager = self.game_manager.get_achievement_manager()
	var s = achievement_manager.get_achievement_state( id )
	self.achievement_element_view.set_state( s )
	# self.achievement_element_view.set_state( AchievementStates.State.COLLECTED )
