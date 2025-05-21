class_name AchievementElement
extends Control

@export var config: AchievementConfig = null : set = set_config
@export var state: AchievementStates.State = AchievementStates.State.UNKNOWN

@onready var icon: TextureRect = %Icon
@onready var name_label: RichTextLabel = %NameLabel

func set_config( new_config: AchievementConfig ) -> void:
	config = new_config

func _ready() -> void:
	if self.config != null:
		self.icon.texture = self.config.icon
		self.name_label.text = self.config.name
	
	match self.state:
		AchievementStates.State.COLLECTED:
			self.modulate = Color.WHITE
		_:
			self.modulate = Color.DIM_GRAY
			
