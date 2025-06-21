@tool

class_name OMG_LaunchControl_LaunchButton
extends MarginContainer

signal triggered( launch_button: OMG_LaunchControl_LaunchButton )

@export var config: OMG_LaunchControl_LaunchButtonConfig = null

@onready var label: Label = %Label

func _ready() -> void:
	self._update_from_config()
	
func _update_from_config() -> void:
	if self.config == null:
		return
	
	if self.label == null:
		return
		
	self.label.text = self.config.label_text

func _on_button_pressed() -> void:
	self.triggered.emit( self )
