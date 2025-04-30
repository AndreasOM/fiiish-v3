extends Node
class_name ZoneEditorManager

@export var scroll_speed: float = 240.0

@onready var _game_manager: GameManager = %GameManager

func _ready():
	Events.zone_edit_enabled.connect(_on_zone_edit_enabled)
	Events.zone_edit_disabled.connect(_on_zone_edit_disabled)
	
func _process(delta: float) -> void:
	var dx = Input.get_axis("left","right")
	if dx != 0.0:
		# print("ZoneEditorManager - dx %f" % dx )
		var move_x = scroll_speed*dx #*delta
			
		if move_x != 0.0:
			if Input.is_action_pressed("zone_editor_move_speed_2"):
				move_x *= 10.0
			self._game_manager.set_move_x( move_x )
	else:
		self._game_manager.set_move_x( 0.0 )

#func _unhandled_input(event: InputEvent) -> void:
#	if event as InputEventMouseMotion != null:
#		return
	#print("ZoneEditorManager - _unhandled_input %s" % event )
#	if event.is_action_pressed("left"):
#		print("ZoneEditorManager - LEFT" )
#	if event.is_action_pressed("right"):
#		print("ZoneEditorManager - RIGHT" )
	
func _on_zone_edit_enabled() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_zone_edit_disabled() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
