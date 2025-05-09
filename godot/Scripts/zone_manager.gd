extends Node
class_name ZoneManager

@export var game_manager: GameManager = null
@export var entity_config_manager: EntityConfigManager = null

var _zone_config_manager: ZoneConfigManager = null
var current_zone_progress: float = 0.0
var current_zone_width: float:
	get:
		if self._current_zone != null:
			return self._current_zone.width
		else:
			return 0.0

var _current_zone: NewZone = null

var _autospawn_on_zone_end: bool = true

func _process(delta: float) -> void:
	self.current_zone_progress += self.game_manager.movement.x
	#self.current_zone_progress += self.game_manager.movement_x * delta
	if self._current_zone != null:
		if self._autospawn_on_zone_end:
			if self.current_zone_progress >= self._current_zone.width:
				self.spawn_zone( true )
	
	if !self.game_manager.game.is_in_zone_editor():
		self._despawn_offscreen_obstacles()
	
func _despawn_offscreen_obstacles() -> void:
	for o in %Obstacles.get_children():
		var n = o as Node2D
		if n == null:
			continue
		if n.position.x < self.game_manager.left_boundary:
			var wo = self.game_manager.left_boundary_wrap_offset
			if wo > 0:
				n.position.x += wo
			else:
				%Obstacles.remove_child(n)
				n.queue_free()

func set_zone_config_manager( zcm: ZoneConfigManager ) -> void:
	self._zone_config_manager = zcm

func cleanup() -> void:
	for o in %Obstacles.get_children():
		%Obstacles.remove_child(o)
		o.queue_free()

func _pick_next_zone() -> NewZone:
	var blocked_zones: Array[ String ] = [ 
		"0000_Start",
		"0000_ILoveFiiish",
		"0000_ILoveFiiishAndRust",
		"8000_MarketingScreenshots",
		"9998_AssetTest",
		"9999_Test"
	]	
	return self._zone_config_manager.pick_next_zone( blocked_zones )

func _spawn_zone_internal( zone: NewZone, spawn_offset: float ) -> void:
	self.current_zone_progress = 0.0
	self._current_zone = zone
	Events.broadcast_zone_changed( zone )
	for l in zone.layers.iter():
		if l.name == "Obstacles" || l.name == "Obstacles_01" || l.name == "Pickups_00":
			for obj in l.objects.iter():


				var o = null
				var ec = entity_config_manager.get_entry( obj.crc )
				if ec != null:
					o = ec.resource.instantiate()
					o.set_meta( "fiiish_nzlo_crc", obj.crc )
					o.game_manager = self.game_manager
					o.position = Vector2( obj.pos_x + spawn_offset, obj.pos_y )
					o.rotation_degrees = obj.rotation
					match ec.entity_type:
						EntityTypes.Id.OBSTACLE:
							%Obstacles.add_child(o)
						EntityTypes.Id.PICKUP:
							%Pickups.add_child(o)
						_ :
							pass
					#print( o )
				else:
					print("Unhandled CRC: %08x" % obj.crc)

func load_and_spawn_zone( filename: String ) -> bool:
	var i = self._zone_config_manager.find_zone_index_by_filename( filename )
	if i < 0:
		push_warning("Zone %s not found" % filename)
		return false

	var zone = self._zone_config_manager.get_zone( i )
	self._spawn_zone_internal( zone, 0.0 )
	
	self._autospawn_on_zone_end = false
	return true
	
func spawn_zone( autospawn_on_zone_end: bool = false ):
	#var xs = [ 1200.0, 1500.0, 1800.0 ]
	#var y = 410.0
	#for x in xs:
		#var o = _rock_b.instantiate()
		#o.game_manager = self
		#o.position = Vector2( x, y )
		#%Obstacles.add_child(o)

	self._autospawn_on_zone_end = autospawn_on_zone_end
	var zone = null
	var next_zone = self._zone_config_manager.pop_next_zone()
		
	if next_zone >= 0 && next_zone < self._zone_config_manager.zone_count():
		zone = self._zone_config_manager.get_zone( next_zone )
	else:
		zone = self._pick_next_zone()
#	if self._zone != null:
	if zone != null:
		self._spawn_zone_internal( zone, self.game_manager.zone_spawn_offset )
	else:
		push_warning("No zone found to spawn")

func add_current_to_new_zone( new_zone: NewZone, offset_x: float ) -> void:
	var obstacle_layer = new_zone.ensure_layer( "Obstacles" )
	for c in %Obstacles.get_children():
		var crc = c.get_meta( "fiiish_nzlo_crc"  )
		if crc == null:
			continue
		var o = c as Obstacle
		if o == null:
			continue
		var nzlo = NewZoneLayerObject.new()
		nzlo.id = 0xffff
		nzlo.crc = crc
		nzlo.pos_x = o.position.x + offset_x
		nzlo.pos_y = o.position.y
		nzlo.rotation = o.rotation_degrees
		
		obstacle_layer.add_object( nzlo )

	var pickup_layer = new_zone.ensure_layer( "Pickups_00" )
	for c in %Pickups.get_children():
		var crc = c.get_meta( "fiiish_nzlo_crc"  )
		if crc == null:
			continue
		var o = c as Pickup
		if o == null:
			continue
		var nzlo = NewZoneLayerObject.new()
		nzlo.id = 0xffff
		nzlo.crc = crc
		nzlo.pos_x = o.position.x + offset_x
		nzlo.pos_y = o.position.y
		nzlo.rotation = o.rotation_degrees
		
		pickup_layer.add_object( nzlo )
		

	# :HACK:		
	# find object furthest to the right
	var max_x = -9999.9
	for l in new_zone.layers.iter():
		var layer = l as NewZoneLayer
		for o in layer.objects.iter():
			var obj = o as NewZoneLayerObject
			max_x = maxf( obj.pos_x, max_x )

	new_zone.width = max_x
