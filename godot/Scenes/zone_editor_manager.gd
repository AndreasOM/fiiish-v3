extends Node
class_name ZoneEditorManager

@export var scroll_speed: float = 240.0
@export var vertical_speed: float = 240.0

@onready var _game_manager: GameManager = %GameManager
@onready var debug_cursor_sprite_2d: Sprite2D = %DebugCursorSprite2D
@onready var _game_scaler: GameScaler = %GameScaler
@onready var cursor_ray_cast_2d: RayCast2D = %CursorRayCast2D

var _mouse_hover_enabled = false
var _mouse_x: float = 0.0

var _offset_x: float = 0.0

var _pending_offset_from_load: Vector2 = Vector2.ZERO
var _zone_filename: String = ""

var _dx: float = 0.0
var _dy: float = 0.0

var _hovered_objects: Dictionary[ Node2D, Vector2 ] = {}

var _select_press_position: Vector2 = Vector2.ZERO
var _selected_object: Node2D = null
var _selected_object_original_scale: Vector2 = Vector2.ONE
var _selected_object_original_modulate: Color = Color.WHITE

var _cursor_offset_index: int = 0
const _CURSOR_OFFSETS: Array[ float ] = [ 0.0, 10.0, 20.0, 40.0 ]

func _ready():
	Events.zone_edit_enabled.connect(_on_zone_edit_enabled)
	Events.zone_edit_disabled.connect(_on_zone_edit_disabled)
	
	
func _process_selected_object(delta: float) -> void:
	if self._selected_object == null:
		return
	var t = 0.001*Time.get_ticks_msec()
	# var s = 1.0 + abs(0.2*sin( 4*t ))
	# self._selected_object.scale = lerp(s*self._selected_object_original_scale,self._selected_object.scale, 0.9)
	
	var m = Color.WHITE
	m.a = clampf( 0.95 + 0.25*sin( 12.0*t ), 0.0, 1.0 )
	m.r = clampf( 1.25 + 1.0*sin( 6.0*t + 1.0 ), 0.0, 1.0 )
	m.g = clampf( 1.25 + 1.0*sin( 6.0*t + 2.0 ), 0.0, 1.0 )
	m.b = clampf( 1.25 + 1.0*sin( 6.0*t + 3.0 ), 0.0, 1.0 )
	self._selected_object.modulate = m
	
func _process(delta: float) -> void:
	self._process_selected_object( delta )
	
	var dx = _dx
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
	#var dy = Input.get_axis("zone_editor_up","zone_editor_down")
	
	var dy = self._dy
	dy *= self.vertical_speed
	dy *= delta
	self._game_manager.move_fish( Vector2( 0.0, dy ) )

func _update_cursor_position( mouse_event: InputEventMouse ) -> void:
	var tr = self._game_scaler.transform
	tr = tr.affine_inverse()
	var p = mouse_event.position
	p = tr * p
	var cursor_offset = self._CURSOR_OFFSETS[ self._cursor_offset_index ]
	p += cursor_offset*Vector2( -1.0, -1.0 )
	self.debug_cursor_sprite_2d.position = p
	self.cursor_ray_cast_2d.position = p
	
func _handle_mouse_hover( mouse_motion_event: InputEventMouseMotion ) -> void:
	if !_mouse_hover_enabled:
		return
		
	var tr = self._game_scaler.transform
	tr = tr.affine_inverse()
	var p = mouse_motion_event.position
	p = tr * p
	
	var cs = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	cs.shape = circle
	
	var max_radius = 24.0 # for testing: 256.0
	var max_objects = 1
	var radius = max_radius
	
	var new_objects := self._game_manager.zone_manager.get_pickups_in_radius( p, radius )

	var tuple_objects = []
	for k in new_objects.keys():
		var v = new_objects[ k ]
		tuple_objects.push_back( [k,v] )
	
	tuple_objects.sort_custom(func(a, b): return a[1] < b[1])
	
	var limit = min( max_objects, tuple_objects.size() )
	
	var objects: Array[ Node2D ] = []
	for i in range( limit ):
		var e = tuple_objects[ i ]
		objects.push_back( e[ 0 ] )
	
	if self.cursor_ray_cast_2d.is_colliding():
		var co = self.cursor_ray_cast_2d.get_collider()
		var ow = co.owner # :danger: we assume internals here
		objects.push_back( ow )
		
	if objects.size() > 0:
		for o in objects:
			if !_hovered_objects.has( o ):
				_hovered_objects[ o ] = o.scale
				o.scale = Vector2(1.5, 1.5)
		
	var to_erase: Array[ Node2D ] = []
	for ho in _hovered_objects.keys():
		if !objects.has( ho ):
			var s = _hovered_objects[ ho ]
			ho.scale = s
			to_erase.push_back( ho )
			# bad idea! _hovered_objects.erase( ho )
			
	for ho in to_erase:
		_hovered_objects.erase( ho )

	# print( "Found %d" % objects.size() )
	
func _select_object( n: Node2D ) -> void:
	self._selected_object = n
	self._selected_object_original_scale = n.scale
	self._selected_object_original_modulate = n.modulate
	
func _deselect_object() -> void:
	if self._selected_object == null:
		return
	self._selected_object.scale = self._selected_object_original_scale
	self._selected_object.modulate = self._selected_object_original_modulate
	self._selected_object = null

func _find_object_at_cursor( ) -> Node2D:
	if self.cursor_ray_cast_2d.is_colliding():
		var co = self.cursor_ray_cast_2d.get_collider()
		var ow = co.owner # :danger: we assume internals here
		var n = ow as Node2D
		return n
		
	var max_radius = 24.0

	var tuple_objects = self._game_manager.zone_manager.get_pickups_in_radius_sorted_by_distance(
															self.cursor_ray_cast_2d.position,
															max_radius,
															1
						)
	if !tuple_objects.is_empty():
		return tuple_objects[ 0 ][ 0 ]
			
	return null
	
func _handle_mouse_button( mouse_button_event: InputEventMouseButton ) -> void:
	self._update_cursor_position( mouse_button_event )
	if mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	## select on release
	if mouse_button_event.pressed == false:
		var mouse_delta: Vector2 = self.debug_cursor_sprite_2d.position - self._select_press_position
		var d = mouse_delta.length_squared()
		if d < 10.0:	# only select if we didn't move to far
			var n = _find_object_at_cursor()
			if n != null:
				if n != self._selected_object:		# new/changed selection
					_deselect_object()
					_select_object( n )
				else:								# same selection
					_deselect_object()
					n.queue_free()	# :HACK:
	else:
		self._select_press_position = self.debug_cursor_sprite_2d.position # :HACK: to avoid recalculation
	
func _unhandled_input(event: InputEvent) -> void:
	self._dx = Input.get_axis("left","right")
	self._dy = Input.get_axis("zone_editor_up","zone_editor_down")
	
	var mouse_button_event := event as InputEventMouseButton
	var mouse_motion_event := event as InputEventMouseMotion
	if mouse_button_event != null:
		self._handle_mouse_button( mouse_button_event )
	elif mouse_motion_event != null:
		if mouse_motion_event.button_mask != MouseButtonMask.MOUSE_BUTTON_MASK_LEFT:
			self._handle_mouse_hover(mouse_motion_event)
		else:
			_update_cursor_position( mouse_motion_event )
			self._mouse_x = -mouse_motion_event.relative.x
		pass
	else:
		print("event %s" % event)

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
	
	var filename = zes.get_last_zone_filename()
	
	# :HACK: until we have a load dialog
	if filename == "":
		self._game_manager.zone_manager.cleanup()
	else:
		if filename.begins_with("user-"):
			var f = filename.trim_prefix( "user-" )
			self._game_manager.get_zone_config_manager().reload_zone( "user://zones", f, "user")
			print( "ZoneEditorManager: Reload Zone %s" % filename )
		self._game_manager.zone_manager.load_and_spawn_zone( filename )
		self._zone_filename = filename
		print("ZoneEditorManager: Loaded from %s - width %f" % [ filename, self._game_manager.zone_manager.current_zone_width ] )
	
	# self.debug_cursor_sprite_2d.visible = true

func _on_zone_edit_disabled() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	# self._game_manager.cleanup()
	self._game_manager.goto_dying_without_result()
	
	# autosave
	var player = self._game_manager.game.get_player()
	var zes = player.get_zone_editor_save()
	zes.set_offset( Vector2( self._offset_x, 0.0 ) )
	zes.set_last_zone_filename( self._zone_filename )
	self._game_manager.game.save_player()

	self.debug_cursor_sprite_2d.visible = false
	
	# cleanup
	self._hovered_objects.clear()
	self._selected_object = null

func select_zone( filename: String ) -> void:
	#if filename != self._zone_filename:
		self._zone_filename = filename
		self._game_manager.cleanup()
		if filename.begins_with("user-"):
			var f = filename.trim_prefix( "user-" )
			self._game_manager.get_zone_config_manager().reload_zone( "user://zones", f, "user")
			print( "ZoneEditorManager: Reload Zone %s" % filename )
		self._game_manager.zone_manager.load_and_spawn_zone( filename )
		self._offset_x = 0.0
		print( "ZoneEditorManager: Switched to Zone %s" % filename )
	# cleanup
		self._hovered_objects.clear()


func select_save_zone( filename: String ) -> void:
	if filename.begins_with("user-"): # Note: If not needed, but we might want to trace, and inform
		filename = filename.trim_prefix( "user-" )
		
	if !filename.ends_with(".nzne"):
		filename = "%s.nzne" % filename
		
	# :TODO: create file if it doesn't exist
	var new_zone: NewZone = NewZone.new()
	
	self._game_manager.zone_manager.add_current_to_new_zone( new_zone, self._offset_x )

	var p = "user://zones/%s" % filename
	var s = Serializer.new()
	if !new_zone.serialize( s ):
		push_warning("Failed serializing NewZone");
	else:
		s.save_file(p)
		print("ZoneEditorManager: Saved to %s - width %f" % [ filename, new_zone.width ] )
	
	self._zone_filename = "user-%s" % filename

func set_cursor_offset( old_cursor_offset: float ) -> float:
	self._cursor_offset_index = ( self._cursor_offset_index + 1 ) % self._CURSOR_OFFSETS.size()
	return self._CURSOR_OFFSETS[ self._cursor_offset_index ]
