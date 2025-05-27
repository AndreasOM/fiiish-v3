@tool

class_name AchievementButton
extends Control

signal pressed( id: String )

@export var config: AchievementConfig = null : set = set_achievement_config
@export var state: AchievementStates.State = AchievementStates.State.UNKNOWN : set = set_state

@onready var texture_button: TextureButton = %TextureButton

var _tween : Tween = null

func _ready() -> void:
	self._update()

func set_achievement_config( c: AchievementConfig ) -> void:
	config = c
	self._update()

func set_state( s: AchievementStates.State ) -> void:
	state = s
	self._update()
	
func _animate_completed() -> void:
	if self._tween != null:
		self._tween.kill()
		
	self._tween = create_tween()
	self._tween.tween_property(
		self,
		"modulate",
		Color.GREEN,
		0.5
	)
	self._tween.tween_property(
		self,
		"modulate",
		Color.WHITE,
		0.5
	)
	self._tween.tween_callback( _completed_tween_finished )
	
func _completed_tween_finished() -> void:
	if self.state == AchievementStates.State.COMPLETED:
		self._animate_completed()
	else:
		self._tween = null

	
func _update() -> void:
	if self.config == null:
		return
		
	if self.texture_button == null:
		return

	self.name = "AchievementButton-%s" % self.config.id
	self.texture_button.texture_normal = self.config.icon

	match self.state:
		AchievementStates.State.COMPLETED:
			self.modulate = Color.WHITE
			self._animate_completed()
			
		AchievementStates.State.COLLECTED:
			self.modulate = Color.WHITE
		_:
			self.modulate = Color.DIM_GRAY


func _on_texture_button_pressed() -> void:
	if self.config == null:
		return
	self.pressed.emit( self.config.id )
