class_name RewardToast
extends Control


@export var icon: Texture = null : set = set_icon
@export var amount: int = 0 : set = set_amount
@export var extra: String = "" : set = set_extra
@onready var amount_label: Label = %AmountLabel
@onready var icon_texture_rect: TextureRect = %IconTextureRect
@onready var extra_label: Label = %ExtraLabel


func _ready() -> void:
	self._update()

func set_icon( i: Texture ) -> void:
	icon = i
	self._update()
func set_amount( a: int ) -> void:
	amount = a
	self._update()
func set_extra( e: String ) -> void:
	extra = e
	self._update()
	
func _update() -> void:
	if self.amount_label == null:
		return
	if self.icon_texture_rect == null:
		return
	if self.extra_label == null:
		return

	if self.icon == null:
		self.amount_label.visible = false
		self.icon_texture_rect.visible = false
	else:
		self.amount_label.visible = true
		self.icon_texture_rect.visible = true
		self.amount_label.text = "%d" % self.amount
		self.icon_texture_rect.texture = self.icon

	
	if self.extra.is_empty():
		self.extra_label.visible = false
	else:
		self.extra_label.visible = true
		self.extra_label.text = self.extra
