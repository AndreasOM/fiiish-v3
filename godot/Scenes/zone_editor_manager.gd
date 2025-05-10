extends Node
class_name ZoneEditorManager

@export var scroll_speed: float = 240.0
@export var vertical_speed: float = 240.0

@onready var _game_manager: GameManager = %GameManager
@onready var debug_cursor_sprite_2d: Sprite2D = %DebugCursorSprite2D
@onready var _game_scaler: GameScaler = %GameScaler
@onready var cursor_ray_cast_2d: RayCast2D = %CursorRayCast2D

var _mouse_x: float = 0.0

var _offset_x: float = 0.0

var _pending_offset_from_load: Vector2 = Vector2.ZERO
var _zone_filename: String = ""

var _dx: float = 0.0
var _dy: float = 0.0

var _hovered_objects: Dictionary[ Node2D, Vector2 ] = {}

func _ready():
	Events.zone_edit_enabled.connect(_on_zone_edit_enabled)
	Events.zone_edit_disabled.connect(_on_zone_edit_disabled)
	
func _process(delta: float) -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	self._dx = Input.get_axis("left","right")
	self._dy = Input.get_axis("zone_editor_up","zone_editor_down")
	
	var mouse_event = event as InputEventMouseMotion
	if mouse_event != null:
		var mouse_motion_event = mouse_event as InputEventMouseMotion
		if mouse_motion_event != null:
			var tr = self._game_scaler.transform
			tr = tr.affine_inverse()
			var p = mouse_motion_event.position
			p = tr * p
			self.debug_cursor_sprite_2d.position = p
			self.cursor_ray_cast_2d.position = p
			var cs = CollisionShape2D.new()
			var circle = CircleShape2D.new()
			cs.shape = circle
			
			var max_radius = 32.0 # for testing: 256.0
			var max_objects = 2 # Note: Other values than 1 not well tested
			var radius = max_radius
			
			# var step_factor = 0.5
			var step_size = max_radius / 2.0
			var objects: Array[ Node2D ] = [] # start with everything
#			while step_factor > ( 1.0/64.0 ):
			while step_size >= 1.0:
				#var new_objects = self._game_manager.zone_manager.get_objects_colliding( p, cs, objects )
				var new_objects = self._game_manager.zone_manager.get_pickups_in_radius( p, radius, objects )
									
				match new_objects.size():
					0:
						# none found
						if radius == max_radius:
							# even at biggest search
							break
						else:
							# we had some before
							step_size *= 0.5
							radius += step_size
							step_size *= 0.5
					1:
						# found
						objects = new_objects
						break
					var n when n <= max_objects:
						objects = new_objects
						break
					_:
						# found more than 1
						radius -= step_size
						step_size *= 0.5
						objects = new_objects
						# continue # not needed since we loop forever
					
			# end of while true
			
			if self.cursor_ray_cast_2d.is_colliding():
				objects.clear()
				var co = self.cursor_ray_cast_2d.get_collider()
				var ow = co.owner # :danger: we assume internals here
				objects.push_back( ow )
				#max_objects += 1
				
			if objects.size() > 0 && objects.size() <= max_objects:
				for o in objects:
					#print("%s" % o)
					if o == null:
						# how
						continue
					if !_hovered_objects.has( o ):
						_hovered_objects[ o ] = o.scale
						o.scale = Vector2(1.5, 1.5)
				
			var to_erase: Array[ Node2D ] = []
			for ho in _hovered_objects.keys():
				if ho == null:
					# how?
					continue
				if !objects.has( ho ):
					var s = _hovered_objects[ ho ]
					ho.scale = s
					to_erase.push_back( ho )
					# bad idea! _hovered_objects.erase( ho )
					
			for ho in to_erase:
				_hovered_objects.erase( ho )

			# print( "Found %d" % objects.size() )
# would be nice :(
#		match mouse_event:
#			is InputEventMouseMotion var mouse_motion_event:
#				pass
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
