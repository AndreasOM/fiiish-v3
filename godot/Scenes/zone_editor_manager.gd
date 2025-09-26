extends Node
class_name ZoneEditorManager

signal command_history_size_changed( history_size: int, future_size: int )
signal zone_name_changed( zone_name: String )
signal zone_difficulty_changed( difficulty: int )
signal zone_width_changed( width: int )

@export var scroll_speed: float = 240.0
@export var vertical_speed: float = 240.0
@export var tool_id: ZoneEditorToolIds.Id = ZoneEditorToolIds.Id.SELECT : set = set_tool_id
@onready var _game_manager: GameManager = %GameManager
@onready var debug_cursor_sprite_2d: Sprite2D = %DebugCursorSprite2D
@onready var _game_scaler: GameScaler = %GameScaler
@onready var cursor_ray_cast_2d: RayCast2D = %CursorRayCast2D
@onready var zone_manager: ZoneManager = %ZoneManager

var _mouse_hover_enabled = false # Note: Hover mode currently not really implemented
var _mouse_x: float = 0.0

var _offset_x: float = 0.0

var _pending_offset_from_load: Vector2 = Vector2.ZERO
var _zone_filename: String = ""
var _zone_name: String = ""
var _zone_difficulty: int = 0
var _zone_width: int = 0
var _zone_minimum_width: int = 0

var _dx: float = 0.0
var _dy: float = 0.0

var _hovered_objects: Dictionary[ Node2D, Vector2 ] = {}

var _select_press_position: Vector2 = Vector2.ZERO
var _selected_object: Node2D = null
var _selected_object_original_scale: Vector2 = Vector2.ONE
var _selected_object_original_modulate: Color = Color.WHITE

var _move_start_position: Vector2 = Vector2.ZERO
var _move_start_offset_x: float = 0.0
var _move_object_start_position: Vector2 = Vector2.ZERO
var _move_object_start_rotation_degrees: float = 0.0

var _spawn_object_crc: int = EntityId.Id.PICKUPCOIN

var _last_cursor_position: Vector2 = Vector2.ZERO

var _cursor_offset_index: int = 0
const _CURSOR_OFFSETS: Array[ float ] = [ 0.0, 10.0, 20.0, 40.0 ]

var _zone_editor_command_handler: ZoneEditorCommandHandler = null

var _right_boundary_entity: Entity = null

func set_tool_id( tid: ZoneEditorToolIds.Id ) -> void:
	tool_id = tid
	
func _ready() -> void:
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
	
	if Input.is_action_just_pressed( "zone_editor_rotate" ):
		self._selected_object.rotation_degrees += 90.0
	
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
	
	self._game_manager.zone_manager.add_zone_offset_x( actual_move_x )

	# up & down
	#var dy = Input.get_axis("zone_editor_up","zone_editor_down")
	
	var dy = self._dy
	dy *= self.vertical_speed
	dy *= delta
	self._game_manager.move_fish( Vector2( 0.0, dy ) )

	match self.tool_id:
		#ZoneEditorToolIds.Id.DELETE:
		#	self._process_for_delete( delta )
		ZoneEditorToolIds.Id.MOVE:
			self._process_for_move( delta )
		ZoneEditorToolIds.Id.SPAWN:
			self._process_for_spawn( delta )
		ZoneEditorToolIds.Id.SELECT:
			self._process_for_select( delta )
		_:
			# :TODO:
			pass

func _process_for_move( _delta: float ) -> void:
	self._update_selected_object_position_for_move()

func _process_for_spawn( _delta: float ) -> void:
	# re-use!
	self._update_selected_object_position_for_move()

func _process_for_select( _delta: float ) -> void:
	if self._selected_object == null:
		return
	if Input.is_action_just_pressed("ZoneEditor_MoveBack"):
		self._move_object_back( self._selected_object )
	if Input.is_action_just_pressed("ZoneEditor_MoveForward"):
		self._move_object_forward( self._selected_object )
	
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

func _handle_mouse_button_for_delete( mouse_button_event: InputEventMouseButton ) -> void:
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
					self._zone_editor_command_handler.add_command_delete( n )
					self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
			else:
				_deselect_object()
	else:
		self._select_press_position = self.debug_cursor_sprite_2d.position # :HACK: to avoid recalculation

func _handle_mouse_button_for_move( mouse_button_event: InputEventMouseButton ) -> void:
	## select on release
	if mouse_button_event.pressed == false:
		var mouse_delta: Vector2 = self.debug_cursor_sprite_2d.position - self._select_press_position
		var d = mouse_delta.length_squared()
		if d < 10.0:	# only select if we didn't move to far
			if self._selected_object == null:
				var n = _find_object_at_cursor()
				if n != null:
					_select_object( n )
					self._move_start_position = self.debug_cursor_sprite_2d.position
					self._move_start_offset_x = self.zone_manager.current_zone_progress
					self._move_object_start_position = self._selected_object.position
					self._move_object_start_rotation_degrees = self._selected_object.rotation_degrees
			else:
				var move = self._selected_object.position - self._move_object_start_position
				### add offset change
				var delta_x = self._offset_x - self._move_start_offset_x
				move.x += delta_x
				self._selected_object.position = self._move_object_start_position
				self._selected_object.position.x -= delta_x
				var rotation = self._selected_object.rotation_degrees - self._move_object_start_rotation_degrees
				self._selected_object.rotation_degrees = self._move_object_start_rotation_degrees
				self._zone_editor_command_handler.add_command_move( self._selected_object, move, rotation )
				_deselect_object()
				
				self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
				if self._zone_minimum_width > self._zone_width:
					self.set_zone_width( self._zone_minimum_width )
				
	else:
		self._select_press_position = self.debug_cursor_sprite_2d.position # :HACK: to avoid recalculation

func _handle_mouse_button_for_rotate( mouse_button_event: InputEventMouseButton ) -> void:
	## select on release
	if mouse_button_event.pressed == false:
		var mouse_delta: Vector2 = self.debug_cursor_sprite_2d.position - self._select_press_position
		var d = mouse_delta.length_squared()
		if d < 10.0:	# only select if we didn't move to far
			var n = _find_object_at_cursor()
			if n != null:
				var rotation = 90.0
				self._zone_editor_command_handler.add_command_move( n, Vector2.ZERO, rotation )
				self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
				if self._zone_minimum_width > self._zone_width:
					self.set_zone_width( self._zone_minimum_width )
	else:
		self._select_press_position = self.debug_cursor_sprite_2d.position # :HACK: to avoid recalculation

func _handle_mouse_button_for_spawn( mouse_button_event: InputEventMouseButton ) -> void:
	## select on release
	if mouse_button_event.pressed == false:
		var mouse_delta: Vector2 = self.debug_cursor_sprite_2d.position - self._select_press_position
		var d = mouse_delta.length_squared()
		if d < 10.0:	# only select if we didn't move to far
			if self._selected_object == null:
				var rotation = 0.0
				var spawn_offset = 0.0
				var node = self._game_manager.zone_manager.spawn_object_from_crc( self._spawn_object_crc, self._select_press_position, rotation, spawn_offset )
				self._selected_object = node
			else:
				var crc = self._selected_object.get_meta("fiiish_nzlo_crc")
				var rotation = self._selected_object.rotation_degrees
				var position = self._selected_object.position
				self._zone_editor_command_handler.add_command_spawn( crc, position, rotation )
				self._selected_object.queue_free()
				self._deselect_object()
				
				self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
				if self._zone_minimum_width > self._zone_width:
					self.set_zone_width( self._zone_minimum_width )
	else:
		self._select_press_position = self.debug_cursor_sprite_2d.position # :HACK: to avoid recalculation

func _handle_mouse_button_for_select( mouse_button_event: InputEventMouseButton ) -> void:
	## select on release
	if mouse_button_event.pressed == false:
		var mouse_delta: Vector2 = self.debug_cursor_sprite_2d.position - self._select_press_position
		var d = mouse_delta.length_squared()
		if d < 10.0:	# only select if we didn't move to far
			if self._selected_object == null:
				var n = _find_object_at_cursor()
				if n != null:
					_select_object( n )
			else:
				_deselect_object()
				
	else:
		self._select_press_position = self.debug_cursor_sprite_2d.position # :HACK: to avoid recalculation

func _handle_mouse_motion( mouse_motion_event: InputEventMouseMotion ) -> void:
	var tr = self._game_scaler.transform
	tr = tr.affine_inverse()
	var cursor_position = mouse_motion_event.position
	cursor_position = tr * cursor_position
	self._last_cursor_position = cursor_position
	
#	match self.tool_id:
		#ZoneEditorToolIds.Id.DELETE:
		#	self._handle_mouse_motion_for_delete( mouse_motion_event )
		#ZoneEditorToolIds.Id.MOVE:
		#	self._handle_mouse_motion_for_move( mouse_motion_event )
#		_:
#			# :TODO:
#			pass
	

func _update_selected_object_position_for_move() -> void:
	if self._selected_object == null:
		return

	var cursor_position = self._last_cursor_position
	var total_delta = cursor_position - self._move_start_position
	var object_target_position = self._move_object_start_position + total_delta
	
	object_target_position.x = maxf( -self._offset_x, object_target_position.x )
	self._selected_object.position = object_target_position

func _handle_mouse_button( mouse_button_event: InputEventMouseButton ) -> void:
	self._update_cursor_position( mouse_button_event )
	if mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
		return
	match self.tool_id:
		ZoneEditorToolIds.Id.DELETE:
			self._handle_mouse_button_for_delete( mouse_button_event )
		ZoneEditorToolIds.Id.MOVE:
			self._handle_mouse_button_for_move( mouse_button_event )
		ZoneEditorToolIds.Id.ROTATE:
			self._handle_mouse_button_for_rotate( mouse_button_event )
		ZoneEditorToolIds.Id.SPAWN:
			self._handle_mouse_button_for_spawn( mouse_button_event )
		ZoneEditorToolIds.Id.SELECT:
			self._handle_mouse_button_for_select( mouse_button_event )
		_:
			# :TODO:
			pass
	
	
func _unhandled_input(event: InputEvent) -> void:
	self._dx = Input.get_axis("left","right")
	self._dy = Input.get_axis("zone_editor_up","zone_editor_down")
	
	var mouse_button_event := event as InputEventMouseButton
	var mouse_motion_event := event as InputEventMouseMotion
#	var key_event := event as InputEventKey
	
	if mouse_button_event != null:
		self._handle_mouse_button( mouse_button_event )
	elif mouse_motion_event != null:
		self._handle_mouse_motion( mouse_motion_event )
		if mouse_motion_event.button_mask != MouseButtonMask.MOUSE_BUTTON_MASK_LEFT:
			self._handle_mouse_hover(mouse_motion_event)
		else:
			_update_cursor_position( mouse_motion_event )
			self._mouse_x = -mouse_motion_event.relative.x
		pass
#	elif key_event != null:
#		if self.tool_id == ZoneEditorToolIds.Id.SELECT:
#			if self._selected_object != null:
#				if !key_event.pressed:
#					if !key_event.echo:
#						match key_event.keycode:
#						#match key_event.physical_keycode:
#							KEY_UP:
#								pass
#							#KEY_DOWN:
#							KEY_K:
#								print(key_event)
#								self._move_object_back( self._selected_object )
	else:
		print("event %s" % event)

func _move_object_back( object: Node2D ) -> void:
	var p = object.get_parent()
	if p == null:
		return
		
	var idx = object.get_index()
	if idx <= 0:
		return
		
	var sidx = idx-1
	var s = p.get_child( sidx )
	p.remove_child( s )
	object.add_sibling( s )
	print("! moved object back")

func _move_object_forward( object: Node2D ) -> void:
	var p = object.get_parent()
	if p == null:
		return
		
	var idx = object.get_index()
		
	var sidx = idx+1
	if sidx >= p.get_child_count():
		return

	var s = p.get_child( sidx )
	p.remove_child( object )
	s.add_sibling( object )
	print("! moved object forward")

func _on_zone_edit_enabled() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	self._zone_editor_command_handler = ZoneEditorCommandHandler.new( self.zone_manager )
	self.command_history_size_changed.emit( 0, 0 ) # ?? redundant?
	self._zone_editor_command_handler.command_history_size_changed.connect( _on_command_history_size_changed )

	# autoload
	var player = self._game_manager.game.get_player()
	var zes = player.get_zone_editor_save()
	var offset = zes.get_offset()
	
	var filename = zes.get_last_zone_filename()
	
	if filename == "":
		self._game_manager.zone_manager.cleanup()
	else:
		self._load_zone( filename )
		self._zone_filename = filename
	
	self._pending_offset_from_load = offset

	self._game_manager.clear_test_zone_filename()
	Events.broadcast_zone_test_disabled()
	# self.debug_cursor_sprite_2d.visible = true


func _on_zone_edit_disabled() -> void:
	self._zone_editor_command_handler = null
	
	self.process_mode = Node.PROCESS_MODE_DISABLED
	# self._game_manager.cleanup()
	# self._game_manager.goto_dying_without_result()
	# self._game_manager.kill_all_fishes()
	
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

	# NO!
	# self._game_manager.clear_test_zone_filename()

func select_zone( filename: String ) -> void:
	self._zone_filename = filename
	self._load_zone( self._zone_filename )

func reload_zone() -> bool:
	var r = self._load_zone( self._zone_filename )
	return r

func _load_zone( filename: String ) -> bool:
	self._game_manager.cleanup()
	if filename.begins_with("user-"):
		var f = filename.trim_prefix( "user-" )
		self._game_manager.get_zone_config_manager().reload_zone( "user://zones", f, "user")
		print( "ZoneEditorManager: Reload Zone %s" % filename )
	self._game_manager.zone_manager.reset_object_ids()
	self._game_manager.zone_manager.load_and_spawn_zone( filename )
	var duplicate_count = self._game_manager.zone_manager.ensure_unique_entity_ids()
	if duplicate_count > 0:
		push_warning("Zone %s had %d duplicate IDs" % [ filename, duplicate_count ])
		
	self._offset_x = 0.0

	self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )

	var current_zone = self._game_manager.zone_manager.get_current_zone()
	if current_zone != null:
		self._zone_name = current_zone.name
		self._zone_difficulty = current_zone.difficulty
		self._zone_width = current_zone.width
	else:
		self._zone_name = ""
		self._zone_difficulty = 0
		self._zone_width = 0
	
	# :HACK:
	var lb_pos = Vector2.ZERO
	self._game_manager.zone_manager.spawn_object_from_crc( EntityId.Id.LEFT_BOUNDARY_ENTITY, lb_pos, 0.0, 0.0 )
	var rb_pos = Vector2( self._zone_width - self._offset_x, 0.0 )
	var n = self._game_manager.zone_manager.spawn_object_from_crc( EntityId.Id.RIGHT_BOUNDARY_ENTITY, rb_pos, 0.0, 0.0 )
	var e = n as Entity
	if e != null:
		self._right_boundary_entity = e

	self.zone_name_changed.emit( self._zone_name )
	self.zone_difficulty_changed.emit( self._zone_difficulty )
	self.zone_width_changed.emit( self._zone_width )

	print( "ZoneEditorManager: Switched to Zone %s" % filename )
	# cleanup
	self._hovered_objects.clear()
	self._deselect_object()
	self._zone_editor_command_handler.clear_history()

	Events.broadcast_global_message("Zone loaded")
	return true

func save_zone() -> bool:
	if !self._zone_filename.begins_with("user-"):
		return false
	var filename = self._zone_filename.trim_prefix( "user-" )
	
	var r = self._save_zone( filename )
	return r

func select_save_zone( filename: String ) -> void:
	if filename.begins_with("user-"): # Note: If not needed, but we might want to trace, and inform
		filename = filename.trim_prefix( "user-" )
		
	if !filename.ends_with(".nzne"):
		filename = "%s.nzne" % filename
		
	if !self._save_zone( filename ):
		# push_warning("")
		return
	
	self._zone_filename = "user-%s" % filename

func set_zone_width( width: float ) -> void:
	if width == self._zone_width:
		return
		
	self._zone_width = maxf( width, self._zone_minimum_width )
	if self._right_boundary_entity != null:
		self._right_boundary_entity.position = Vector2( self._zone_width - self._offset_x, 0.0 )
	self.zone_width_changed.emit( self._zone_width )
	
func _save_zone( filename: String ) -> bool:
	var new_zone: NewZone = NewZone.new()

#	self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
	
	self._game_manager.zone_manager.add_current_to_new_zone( new_zone, self._offset_x )
	new_zone.name = self._zone_name
	new_zone.difficulty = self._zone_difficulty
	if floorf(new_zone.width) <= self._zone_width:
		new_zone.width = self._zone_width
	else:
		push_warning("Tried save zone that is not wide enough %d > %d" % [ new_zone.width, self._zone_width ])
#	else:
#		self._zone_width = new_zone.width
#		self.zone_width_changed.emit( self._zone_width )
#		if self._right_boundary_entity != null:
#			self._right_boundary_entity.position = Vector2( self._zone_width - self._offset_x, 0.0 )

	var p = "user://zones/%s" % filename
	var s = Serializer.new()
	if !new_zone.serialize( s ):
		push_warning("Failed serializing NewZone");
		return false

	s.save_file(p)
	print("ZoneEditorManager: Saved to %s - width %f" % [ filename, new_zone.width ] )
	
	return true

func set_cursor_offset( old_cursor_offset: float ) -> float:
	self._cursor_offset_index = ( self._cursor_offset_index + 1 ) % self._CURSOR_OFFSETS.size()
	return self._CURSOR_OFFSETS[ self._cursor_offset_index ]

func on_tool_selected( tool_id: ZoneEditorToolIds.Id ) -> void:
	match self.tool_id:
		ZoneEditorToolIds.Id.MOVE:
			if self._selected_object != null:
				self._selected_object.position = self._move_object_start_position
				self._selected_object.rotation_degrees = self._move_object_start_rotation_degrees
		ZoneEditorToolIds.Id.SPAWN:
			if self._selected_object != null:
				self._selected_object.queue_free()
		_:
			pass
	self._deselect_object()
	self.tool_id = tool_id

func on_undo_pressed() -> void:
	if self._zone_editor_command_handler.undo():
		self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
		if self._zone_minimum_width > self._zone_width:
			self.set_zone_width( self._zone_minimum_width )
	

func on_redo_pressed() -> void:
	if self._zone_editor_command_handler.redo():
		self._zone_minimum_width = self._game_manager.zone_manager.calculate_zone_width( self._offset_x )
		if self._zone_minimum_width > self._zone_width:
			self.set_zone_width( self._zone_minimum_width )


func command_history_size() -> int:
	if self._zone_editor_command_handler == null:
		return 0
	return self._zone_editor_command_handler.command_history_size()

func _on_command_history_size_changed( history_size: int, future_size: int ) -> void:
	self.command_history_size_changed.emit( history_size, future_size )

func clear_zone() -> void:
	self._deselect_object()
	self._game_manager.cleanup()
	self._zone_editor_command_handler.clear_history()
	Events.broadcast_global_message("Zone cleared")

func on_spawn_entity_changed( id: EntityId.Id ) -> void:
	self._spawn_object_crc = id

func test_zone() -> void:
	# :WIP:
	if self._zone_filename == null || self._zone_filename.is_empty():
		push_warning("Tried to test zone that was never saved")
		return
		
	var filename = self._zone_filename
	if filename.begins_with("user-"): # Note: If not needed, but we might want to trace, and inform
		filename = filename.trim_prefix( "user-" )
		
	if !self._save_zone( filename ):
		push_warning("Saving zone %s for testing failed!" % self._zone_filename)
		return
		
	if self._zone_filename.begins_with("user-"):
		var f = self._zone_filename.trim_prefix( "user-" )
		self._game_manager.get_zone_config_manager().reload_zone( "user://zones", f, "user")
		
	self._game_manager.set_test_zone_filename( self._zone_filename )
	Events.broadcast_zone_test_enabled( self._zone_filename )
	var game = self._game_manager.game
	game.close_zone_editor()
		
func on_zone_name_submitted( new_name: String ) -> void:
	self._zone_name = new_name
	
func get_zone_name() -> String:
	return self._zone_name

func on_zone_difficulty_changed( difficulty: int ) -> void:
	self._zone_difficulty = difficulty
	
func get_zone_difficulty() -> int:
	return self._zone_difficulty

func on_zone_width_changed( width: int ) -> void:
	self.set_zone_width( width )
	
func get_zone_width() -> int:
	return self._zone_width
