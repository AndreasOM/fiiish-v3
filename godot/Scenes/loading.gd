extends Control

func _ready() -> void:
	print("Loading...")
	VersionInfo.print()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
