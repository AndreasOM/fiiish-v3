@tool

extends Control

@onready var button_container: VBoxContainer = %ButtonContainer
const BUTTON_CONFIG_PATH="res://addons/omg-launch_control/launch_button_configs/"
const OMG_LAUNCH_CONTROL_LAUNCH_BUTTON = preload("res://addons/omg-launch_control/omg-launch_control-launch_button.tscn")

func _ready() -> void:
	self.reload()
	
	
func reload() -> void:
	for c in self.button_container.get_children():
		c.queue_free()
	
	var configs = ResourceLoader.list_directory( BUTTON_CONFIG_PATH )
	for cn in configs:
		if !cn.ends_with( ".tres" ):
			continue
		var fcn = "%s/%s" % [ BUTTON_CONFIG_PATH, cn ]
		var c = load( fcn )
		var cfg = c as OMG_LaunchControl_LaunchButtonConfig
		if cfg == null:
			continue
		print("Button Config: %s" % cn)
		
		var button = OMG_LAUNCH_CONTROL_LAUNCH_BUTTON.instantiate()
		button.config = cfg
		button.triggered.connect( _on_launch_button_triggered )
		self.button_container.add_child( button )
	

func _on_launch_button_triggered(launch_button: OMG_LaunchControl_LaunchButton) -> void:
	var parameter = launch_button.config.parameter
	

	ProjectSettings.set_setting("addons/omg-launch_control/launch_parameter", parameter)
	ProjectSettings.save()

	EditorInterface.play_main_scene()


func _on_reload_button_pressed() -> void:
	self.reload()
