extends Control

var _load: bool = true
func _ready() -> void:
	print_rich("[color=green]loading _ready() ->[/color]")
	print("Loading...")
	VersionInfo.print()
	# get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _process(delta: float) -> void:
	print_rich("[color=green]loading _process() ->[/color]")
	if self._load:
		self._load = false
#		var tree = get_tree()
		var e = get_tree().change_scene_to_file("res://Scenes/main.tscn")
		print_rich("[color=yellow]loading result: %s[/color]" % e)
#		await tree.scene_changed
#		print_rich("[color=yellow]loading scene_changed[/color]")


		# get_tree().change_scene_to_file("res://Features/Developer/developer.tscn")
	print_rich("[color=green]<- loading _process()[/color]")
