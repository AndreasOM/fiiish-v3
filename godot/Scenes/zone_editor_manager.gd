extends Node
class_name ZoneEditorManager

@export var scroll_speed: float = 240.0
@export var vertical_speed: float = 240.0

@onready var _game_manager: GameManager = %GameManager

var _mouse_x: float = 0.0

var _offset_x: float = 0.0

var _pending_offset_from_load: Vector2 = Vector2.ZERO

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
	
	move_x *= delta
	# var offset_x = self._offset_x
	# offset_x += move_x
	# var zone_width = 5000.0
	var zone_width = self._game_manager.zone_manager.current_zone_width
	zone_width += self._game_manager.zone_spawn_offset
	var offset_x = clampf( self._offset_x + move_x + self._pending_offset_from_load.x, 0.0, zone_width )
	self._pending_offset_from_load = Vector2.ZERO
	var actual_move_x = offset_x - self._offset_x
	self._offset_x = offset_x
	# print("offset_x %f += %f of %f" % [ offset_x, actual_move_x, zone_width])
	self._game_manager.set_move( Vector2( actual_move_x, 0.0 ) )

	# up & down
	var dy = Input.get_axis("zone_editor_up","zone_editor_down")
	
	dy *= self.vertical_speed
	dy *= delta
	self._game_manager.move_fish( Vector2( 0.0, dy ) )

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
	# autoload
	var player = self._game_manager.game.get_player()
	var zes = player.get_zone_editor_save()
	var offset = zes.get_offset()
	
	self._offset_x = 0.0
	
	# self._offset_x = offset.x
	# Don't! Would be execution order dependend!
	# self._game_manager.set_move( offset )
	
	self._pending_offset_from_load = offset
	
	# should be load_zone( name )
	self._game_manager.zone_manager.spawn_zone( false )

func _on_zone_edit_disabled() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	# self._game_manager.cleanup()
	self._game_manager.goto_dying_without_result()
	
	# autosave
	var player = self._game_manager.game.get_player()
	var zes = player.get_zone_editor_save()
	zes.set_offset( Vector2( self._offset_x, 0.0 ) )
	self._game_manager.game.save_player()
