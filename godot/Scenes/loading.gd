extends Control

var _load: bool = true
func _ready() -> void:
	print("Loading...")
	VersionInfo.print()
	# get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _process(delta: float) -> void:
	if self._load:
		self._load = false
		# get_tree().change_scene_to_file("res://Scenes/main.tscn")
		get_tree().change_scene_to_file("res://Features/Developer/developer.tscn")
