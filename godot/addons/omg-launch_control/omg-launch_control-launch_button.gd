@tool

class_name OMG_LaunchControl_LaunchButton
extends TextureButton

@export var label_text: String = "Launch" : set = _set_label_text
@export var parameter: String = ""

@onready var label: Label = %Label

func _ready() -> void:
	self._update_label()
	
func _set_label_text( l: String ) -> void:
	label_text = l
	
func _update_label() -> void:
	self.label.text = self.label_text
