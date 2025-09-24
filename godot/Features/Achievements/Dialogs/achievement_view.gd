extends Control
class_name AchievementView

@onready var achievement_container: GridContainer = %AchievementContainer
@onready var achievement_element_view: AchievementElementView = %AchievementElementView

@export var game_manager: GameManager = null

var _element = preload("res://Features/Achievements/achievement_element.tscn")
var _button_element = preload("res://Features/Achievements/Dialogs/achievement_button.tscn")
var _selected_achievement_id: String = ""

func _ready() -> void:
	Events.achievement_completed.connect( _on_achievement_completed )
	
func grab_focus_for_achievement() -> void:
	if self._selected_achievement_id == null:
		return
		
	var ab = self._find_achievement_button_by_id( self._selected_achievement_id )
	if ab == null:
		return
		
	ab.grab_focus.call_deferred()
	
func _find_achievement_button_by_id( id: String ) -> AchievementButton:
	for c in self.achievement_container.get_children():
		var ab = c as AchievementButton
		if ab == null:
			continue
		if ab.config.id == id:
			return ab
	
	return null
	
func recreate_achievements() -> void:
	var achievement_config_manager = self.game_manager.game.achievement_config_manager
	var achievement_manager = self.game_manager.game.achievement_manager
	
	for c in self.achievement_container.get_children():
		c.get_parent().remove_child( c )
		c.queue_free()
	
	var keys = achievement_config_manager.get_keys()
	
	if self._selected_achievement_id.is_empty():
		if !keys.is_empty():
			self._selected_achievement_id = keys[ 0 ]
			# self._on_achievement_selected( keys[ 0 ] )
			
	var colums = self.achievement_container.columns
	var i = 0
	
	var last_ab: AchievementButton = null
	
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
		if i < colums:
			ab.disable_up_focus()
		self.achievement_container.add_child( ab )
		ab.set_left_focus( last_ab )
		ab.set_prev_focus( last_ab )
		if last_ab != null:
			last_ab.set_right_focus( ab )
			last_ab.set_next_focus( ab )
			
		last_ab = ab
		i += 1
	
	if last_ab != null:
		last_ab.set_next_focus( null )
		last_ab.set_right_focus( null )
	
func update_achievements() -> void:
	var achievement_config_manager = self.game_manager.game.achievement_config_manager
	var achievement_manager = self.game_manager.game.achievement_manager
	
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
	
func _on_achievement_completed( id: String ) -> void:
	for c in self.achievement_container.get_children():
		var ab =  c as AchievementButton
		if ab == null:
			continue
		if ab.config.id == id:
			ab.state = AchievementStates.State.COMPLETED

func _on_achievement_selected( id: String ) -> void:
	var achievement_config_manager = self.game_manager.game.achievement_config_manager
	var achievement_manager = self.game_manager.game.achievement_manager
	var ac = achievement_config_manager.get_config( id )
	var s = achievement_manager.get_achievement_state( id )

	self.achievement_element_view.config = ac
	self.achievement_element_view.state = s
	self._selected_achievement_id = id
	self._update_selection()

func _on_achievement_element_view_collect_pressed(id: String) -> void:
	if !self.game_manager.game.collect_achievement( id ):
		return
	self.update_achievements()
	var achievement_manager = self.game_manager.game.achievement_manager
	var s = achievement_manager.get_achievement_state( id )
	self.achievement_element_view.set_state( s )
	# self.achievement_element_view.set_state( AchievementStates.State.COLLECTED )

func collect_selected_achievement() -> bool:
	if self._selected_achievement_id == "":
		return false
	self._on_achievement_element_view_collect_pressed( self._selected_achievement_id )
	return true
	
