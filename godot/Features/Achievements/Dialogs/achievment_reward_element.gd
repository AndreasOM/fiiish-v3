class_name AchievementRewardElement
extends HBoxContainer

@export var icon: Texture = null
@export var value: int = 0 : set = set_value
@onready var icon_texture: TextureRect = %IconTexture
@onready var value_label: Label = %ValueLabel

func _ready() -> void:
	self.icon_texture.texture = icon
	self._update()

func set_value( v: int ) -> void:
	value = v
	self._update()
	
func _update() -> void:
	if self.value_label == null:
		return
	self.value_label.text = "%d" % self.value
	if self.value == 0:
		self.modulate = Color.TRANSPARENT
	else:
		self.modulate = Color.WHITE
