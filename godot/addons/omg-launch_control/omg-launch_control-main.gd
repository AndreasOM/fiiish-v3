@tool

extends Control


func _on_launch_button_triggered(launch_button: OMG_LaunchControl_LaunchButton) -> void:
	var parameter = launch_button.parameter

	ProjectSettings.set_setting("addons/omg-launch_control/launch_parameter", parameter)
	ProjectSettings.save()

	EditorInterface.play_main_scene()
