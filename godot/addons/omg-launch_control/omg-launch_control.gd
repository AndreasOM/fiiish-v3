@tool
extends EditorPlugin

const OMG_LAUNCH_CONTROL = preload("res://addons/omg-launch_control/omg-launch_control.tscn")

var _instance

func _enter_tree() -> void:
	self._instance = OMG_LAUNCH_CONTROL.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(self._instance)
	# Hide the main panel. Very much required.
	_make_visible(false)

func _exit_tree() -> void:
	if self._instance:
		self._instance.queue_free()

func _has_main_screen():
	return true


func _make_visible(visible):
	if self._instance:
		self._instance.visible = visible


func _get_plugin_name():
	return "OMG Launch Control Plugin"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
