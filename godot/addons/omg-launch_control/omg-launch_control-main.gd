@tool

extends Control


func _on_launch_button_pressed() -> void:
	print("launch")
	ProjectSettings.set_setting("addons/omg-launch_control/launch_parameter", "")
	ProjectSettings.save()
	
	EditorInterface.play_main_scene()

func _on_kids_mode_disable_launch_button_pressed() -> void:
	ProjectSettings.set_setting("addons/omg-launch_control/launch_parameter", "KidsModeDisable")
	ProjectSettings.save()

	EditorInterface.play_main_scene()
