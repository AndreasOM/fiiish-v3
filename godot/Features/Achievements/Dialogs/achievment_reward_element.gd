class_name AchievementRewardElement
extends HBoxContainer

@export var icon: Texture = null
@export var value: int = 0 : set = set_value
@export var minimum_value_width_override: int = 0
@onready var icon_texture: TextureRect = %IconTexture
@onready var value_label: Label = %ValueLabel

func _ready() -> void:
	self.icon_texture.texture = icon
	self._update()
	if self.minimum_value_width_override > 0:
		self.value_label.custom_minimum_size.x = self.minimum_value_width_override

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
