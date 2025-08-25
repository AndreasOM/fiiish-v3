@tool

class_name AchievementButton
extends Control

signal pressed( id: String )

@export var config: AchievementConfig = null : set = set_achievement_config
@export var state: AchievementStates.State = AchievementStates.State.UNKNOWN : set = set_state
@export var selected: bool = false : set = set_selected

@onready var texture_button: TextureButton = %TextureButton
@onready var selected_texture_rect: TextureRect = %SelectedTextureRect

var _tween : Tween = null

func _ready() -> void:
	self._update()

func set_achievement_config( c: AchievementConfig ) -> void:
	config = c
	self._update()

func set_state( s: AchievementStates.State ) -> void:
	state = s
	self._update()

func set_selected( s: bool ) -> void:
	selected = s
	self._update()
	
func _animate_completed() -> void:
	if self._tween != null:
		self._tween.kill()
		
	self._tween = create_tween()
	self._tween.tween_property(
		self.texture_button,
		"modulate",
		Color.GREEN,
		0.5
	)
	self._tween.tween_property(
		self.texture_button,
		"modulate",
		Color.WHITE,
		0.5
	)
	self._tween.tween_callback( _completed_tween_finished )

func _animate_demo() -> void:
	if self._tween != null:
		self._tween.kill()
		
	self._tween = create_tween()
	self._tween.tween_property(
		self.texture_button,
		"modulate",
		#Color.TRANSPARENT,
		Color(1, 1, 0.5, 0.1),
		1.5
	)
	self._tween.tween_property(
		self.texture_button,
		"modulate",
		Color(1, 1, 0.25, 0.2),
		1.5
	)
	self._tween.tween_callback( _completed_tween_finished )
	
func _completed_tween_finished() -> void:
	if self.config.disabled_in_demo && FeatureTags.has_feature("demo"):
		# self.texture_button.modulate = Color.HOT_PINK
		self._animate_demo()
		return

	match self.state:
		AchievementStates.State.COLLECTED:
			self.texture_button.modulate = Color.WHITE
			self._tween = null
		AchievementStates.State.COMPLETED:
			self._animate_completed()
		_:
			self.texture_button.modulate = Color.DIM_GRAY
			self._tween = null
			
	
func _update() -> void:
	if self.config == null:
		return
		
	if self.texture_button == null:
		return
	
	if self.selected_texture_rect == null:
		return

	self.name = "AchievementButton-%s" % self.config.id
	self.texture_button.texture_normal = self.config.icon

	match self.state:
		AchievementStates.State.COMPLETED:
			self.texture_button.modulate = Color.WHITE
			self._animate_completed()
			
		AchievementStates.State.COLLECTED:
			self.texture_button.modulate = Color.WHITE
		_:
			self.texture_button.modulate = Color.DIM_GRAY

	if self.config.disabled_in_demo && FeatureTags.has_feature("demo"):
		# self.texture_button.modulate = Color.HOT_PINK
		self._animate_demo()
		
	self.selected_texture_rect.visible = self.selected

func _on_texture_button_pressed() -> void:
	if self.config == null:
		return
	self.pressed.emit( self.config.id )
