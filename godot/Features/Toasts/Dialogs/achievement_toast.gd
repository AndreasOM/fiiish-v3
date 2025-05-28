class_name AchievementToast
extends Control


@export var config: AchievementConfig = null : set = set_config
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel


func _ready() -> void:
	self._update()

func set_config( c: AchievementConfig ) -> void:
	config = c
	self._update()
	
func _update() -> void:
	if self.icon == null:
		return
	if self.name_label == null:
		return
	if self.config == null:
		return

	self.icon.texture = self.config.icon
	self.name_label.text = self.config.name
