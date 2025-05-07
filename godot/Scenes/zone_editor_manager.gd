extends Node
class_name ZoneEditorManager

@export var scroll_speed: float = 240.0

@onready var _game_manager: GameManager = %GameManager

var _mouse_x: float = 0.0

var _offset_x: float = 0.0

func _ready():
	Events.zone_edit_enabled.connect(_on_zone_edit_enabled)
	Events.zone_edit_disabled.connect(_on_zone_edit_disabled)
	
func _process(delta: float) -> void:
	var dx = Input.get_axis("left","right")
	var move_x = 0.0
	if dx != 0.0:
		# print("ZoneEditorManager - dx %f" % dx )
		var m_x = scroll_speed*dx #*delta
			
		if m_x != 0.0:
			if Input.is_action_pressed("zone_editor_move_speed_2"):
				m_x *= 10.0
			move_x += m_x

	self._mouse_x = lerpf( self._mouse_x, 0.0, 0.1 )
	move_x += self._mouse_x * ( 1.0/delta)
	
	self._game_manager.set_move_x( move_x )
	
	move_x *= delta
	self._game_manager.set_move( Vector2( move_x, 0.0 ) )

func _unhandled_input(event: InputEvent) -> void:
	var mouse_event = event as InputEventMouseMotion
	if mouse_event != null:
		if mouse_event.button_mask == MouseButtonMask.MOUSE_BUTTON_MASK_LEFT:
			self._mouse_x = -mouse_event.relative.x
			#print("ZoneEditorManager - _unhandled_input InputEventMouseMotion %s" % event )
		return
	#print("ZoneEditorManager - _unhandled_input %s" % event )
#	if event.is_action_pressed("left"):
#		print("ZoneEditorManager - LEFT" )
#	if event.is_action_pressed("right"):
#		print("ZoneEditorManager - RIGHT" )
	
func _on_zone_edit_enabled() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_zone_edit_disabled() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
