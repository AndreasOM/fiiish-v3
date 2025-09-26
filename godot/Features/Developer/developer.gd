extends Control
@onready var font_size_test_v_box_container: VBoxContainer = %FontSizeTestVBoxContainer

@onready var current_working_directory_label: Label = %CurrentWorkingDirectoryLabel
@onready var developer_overlay_toggle_button: FiiishUI_ToggleButton = %DeveloperOverlayToggleButton

var _settings: Settings = null
func _ready() -> void:
	
	self._settings = Settings.load()
	
	if self._settings.dev_is_developer_overlay_enabled():
		self.developer_overlay_toggle_button.goto_a()
	else:
		self.developer_overlay_toggle_button.goto_b()
	var da = DirAccess.open("")
	var cwd = da.get_current_dir()

	self.current_working_directory_label.text = cwd
		
	#const SIZES = [ 8, 16, 32, 64, 128, 256 ]
	
	for c in self.font_size_test_v_box_container.get_children():
		c.get_parent().remove_child( c )
		c.queue_free()

	var s = 8
	while s<128:
	#for s in SIZES:
		var l = FontSizeTestLabel.new()
		l.font_size = s
		l.name = "FontSizeTestLabel-%d" % s
		l.add_theme_constant_override("outline_size", 8)
		self.font_size_test_v_box_container.add_child( l )
		s *= 1.2


func _on_quit_button_pressed() -> void:
	self._settings.save()
	get_tree().quit(0)


func _on_developer_overlay_toggle_button_toggled(state: FiiishUI_ToggleButton.ToggleState) -> void:
	match state:
		FiiishUI_ToggleButton.ToggleState.B:
			self._settings.dev_disable_developer_overlay()
		FiiishUI_ToggleButton.ToggleState.A:
			self._settings.dev_enable_developer_overlay()


func _on_game_button_pressed() -> void:
	self._settings.save()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
