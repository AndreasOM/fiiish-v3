@tool
class_name ShopFrameTitleContainer
extends MarginContainer

signal close_button_pressed

@onready var title_label: Label = %TitleLabel
@onready var close_button: TextureButton = %CloseButton

@export var title: String = "" : set = set_title

func _ready():
	_update_title()
	
func set_title( t: String ) -> void:
	title = t
	self._update_title()

func _update_title():
	if self.title_label == null:
		return
		
	self.title_label.text = self.title

func _on_close_button_pressed() -> void:
	self.close_button_pressed.emit()
