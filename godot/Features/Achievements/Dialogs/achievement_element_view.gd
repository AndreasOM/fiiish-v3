class_name AchievementElementView
extends MarginContainer

signal collect_pressed( id: String )

@export var config: AchievementConfig = null : set = set_achievement_config
@export var state: AchievementStates.State = AchievementStates.State.UNKNOWN : set = set_state
@onready var icon: TextureRect = %Icon
@onready var name_label: RichTextLabel = %NameLabel
@onready var collect_texture_button: TextureButton = %CollectTextureButton

func _ready() -> void:
	self._update()

func set_achievement_config( c: AchievementConfig ) -> void:
	config = c
	self._update()

func set_state( s: AchievementStates.State ) -> void:
	state = s
	self._update()


func _update() -> void:
	if self.config == null:
		return
		
	if self.icon == null:
		return

	if self.name_label == null:
		return

	#self.name = "AchievementElementView-%s" % self.config.id
	self.icon.texture = self.config.icon
	self.name_label.text = self.config.name
	
	match self.state:
		AchievementStates.State.UNKNOWN:
			self.collect_texture_button.visible = false
			self.icon.modulate = Color.DIM_GRAY
		AchievementStates.State.COMPLETED:
			self.collect_texture_button.visible = true
			self.icon.modulate = Color.WHITE
		AchievementStates.State.COLLECTED:
			self.collect_texture_button.visible = false
			self.icon.modulate = Color.WHITE
		_:
			self.collect_texture_button.visible = false
			self.icon.modulate = Color.WHITE


func _on_collect_texture_button_pressed() -> void:
	if self.state != AchievementStates.State.COMPLETED:
		return
	if self.config == null:
		return
		
	self.collect_pressed.emit( self.config.id )
