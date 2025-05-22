class_name SimpleTextToast
extends Control

@export var text: String = "" : set = set_text

@onready var label: Label = %Label

func _ready() -> void:
	self.label.text = self.text

func set_text( t: String ) -> void:
	text = t
	if self.label != null:
		self.label.text = self.text
