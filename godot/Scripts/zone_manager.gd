extends Node
class_name ZoneManager

@export var game_manager: GameManager = null
@export var entity_config_manager: EntityConfigManager = null

var _zone_offset_x: float = 0.0

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
var _next_object_id = 1

func _process(_delta: float) -> void:
	self.current_zone_progress += self.game_manager.movement.x
	#self.current_zone_progress += self.game_manager.movement_x * delta
	if self._current_zone != null:
		if self.current_zone_progress >= self._current_zone.width:
			Events.broadcast_zone_finished()
			if self._autospawn_on_zone_end:
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

func get_current_zone() -> NewZone:
	return self._current_zone
	
func get_current_zone_name() -> String:
	if self._current_zone == null:
		return ""
	
	return self._current_zone.name
	
func set_zone_config_manager( zcm: ZoneConfigManager ) -> void:
	self._zone_config_manager = zcm

func cleanup() -> void:
	for o in %Obstacles.get_children():
		%Obstacles.remove_child(o)
		o.queue_free()
	for a in %Areas.get_children():
		%Areas.remove_child(a)
		a.queue_free()

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

func _spawn_object( ec: EntityConfig, position: Vector2, rotation_degrees: float, spawn_offset: float) -> Entity:
	var o: Node = ec.resource.instantiate()
	var e = o as Entity
	if e == null:
		o.queue_free()
		return null
		
	e.game_manager = self.game_manager
	e.position = Vector2( position.x + spawn_offset, position.y )
	e.rotation_degrees = rotation_degrees
	match ec.entity_type:
		EntityTypes.Id.OBSTACLE:
			%Obstacles.add_child(e)
		EntityTypes.Id.PICKUP:
			%Pickups.add_child(e)
		EntityTypes.Id.AREA:
			%Areas.add_child(e)
		_ :
			# !!!!
			pass
	
	return e
	
func spawn_object_from_crc( crc: int, position: Vector2, rotation_degrees: float, spawn_offset: float) -> Node2D:
	var ec = entity_config_manager.get_entry( crc )
	if ec == null:
		push_warning("Entity config for 0x%08x not found" % crc)
		return null
	var o = self._spawn_object( ec, position, rotation_degrees, spawn_offset )
	if o == null:
		return null
		
	o.set_meta( "fiiish_nzlo_crc", crc )
	return o
	
func spawn_new_zone_layer_object( nzlo: NewZoneLayerObject, spawn_offset: float ) -> bool:
	var position = Vector2( nzlo.pos_x, nzlo.pos_y )
	var o = self.spawn_object_from_crc( nzlo.crc, position, nzlo.rotation, spawn_offset )
	if o == null:
		return false
	if nzlo.id != 0xffff:
		o.set_meta( "fiiish_nzlo_id", nzlo.id )
		if nzlo.id >= self._next_object_id:
			print("Updated next object id 0x%04x" % self._next_object_id )
			self._next_object_id = nzlo.id + 1
		
	return true
	
func _spawn_zone_internal( zone: NewZone, spawn_offset: float ) -> void:
	self.current_zone_progress = 0.0
	self._current_zone = zone
	Events.broadcast_zone_changed( zone )
	for l in zone.layers.iter():
		if l.name == "Obstacles" || l.name == "Obstacles_01" || l.name == "Pickups_00":
			for obj in l.objects.iter():
				var nzlo := obj as NewZoneLayerObject
				if nzlo == null:
					push_warning("Tried to spawn non NewZoneLayerObject")
					continue
				self.spawn_new_zone_layer_object( nzlo, spawn_offset )
		elif l.name == "Debug" || l.name == "Pickups_Debug":
			pass
		else:
			print("Skipping layer %s" % l.name )

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

func create_new_zone_layer_object_from_node( node: Node2D, offset_x: float ) -> NewZoneLayerObject:
	var crc = node.get_meta( "fiiish_nzlo_crc"  )
	if crc == null:
		return null
	var id = node.get_meta( "fiiish_nzlo_id", 0xffff  )
	
	var o = node as Obstacle
	if o != null:
		var nzlo = NewZoneLayerObject.new()
		nzlo.id = id
		nzlo.crc = crc
		nzlo.pos_x = node.position.x + offset_x
		nzlo.pos_y = node.position.y
		nzlo.rotation = node.rotation_degrees
		return nzlo
	
	var p = node as Pickup
	if p != null:
		var nzlo = NewZoneLayerObject.new()
		nzlo.id = id
		nzlo.crc = crc
		nzlo.pos_x = node.position.x + offset_x
		nzlo.pos_y = node.position.y
		nzlo.rotation = node.rotation_degrees
		return nzlo
	
	return null
	
	
func add_children_to_new_zone_layer( node: Node2D, layer: NewZoneLayer, offset_x ) -> void:
	for c in node.get_children():
		var nzlo = self.create_new_zone_layer_object_from_node( c, offset_x )
		if nzlo == null:
			continue
		layer.add_object( nzlo )
	
func get_max_pos_x_on_layer( layer_node: Node2D ) -> float:
	var max_x = -9999.9
	for c in layer_node.get_children():
		max_x = maxf( c.position.x, max_x )
		
	return max_x
	
func get_max_pos_x() -> float:
	var obstacles_max_x = self.get_max_pos_x_on_layer( %Obstacles )
	var pickups_max_x = self.get_max_pos_x_on_layer( %Pickups )
	var max_x = maxf( obstacles_max_x, pickups_max_x )
	return max_x
	
func add_current_to_new_zone( new_zone: NewZone, offset_x: float ) -> void:
	var obstacle_layer = new_zone.ensure_layer( "Obstacles" )
	self.add_children_to_new_zone_layer( %Obstacles, obstacle_layer, offset_x )
			
	var pickup_layer = new_zone.ensure_layer( "Pickups_00" )
	self.add_children_to_new_zone_layer( %Pickups, pickup_layer, offset_x )

	var max_x = self.calculate_zone_width( offset_x )
	new_zone.width = max_x

func calculate_zone_width( offset_x: float ) -> float:
	var max_x = self.get_max_pos_x() + offset_x
	return max_x

func get_pickups_in_radius_sorted_by_distance( position: Vector2, radius: float, max_objects: int ) -> Array:
	var pickups := self.get_pickups_in_radius( position, radius )
	
	var sorted_pickups = []		# key = node, value = distance
	for k in pickups.keys():
		var distance = pickups[ k ]
		sorted_pickups.push_back( [k,distance] )
	
	# sort by distance, closest first
	sorted_pickups.sort_custom(func(a, b): return a[1] < b[1])

	var limit = min( max_objects, sorted_pickups.size() )
	sorted_pickups.resize( limit )
	
	return sorted_pickups
	
func get_pickups_in_radius( position: Vector2, radius: float ) -> Dictionary[ Node2D, float ]:
	var radius_sqr = radius*radius
	
	var candidates = []
	for c in %Pickups.get_children():
		var n = c as Node2D
		if n == null:
			continue
		candidates.push_back( n )
		
	var objects: Dictionary[ Node2D, float ] = {}
	
	for c in candidates:
		var n = c as Node2D
		if n == null:
			continue
			
		var p = n.position
		var d = p - position
		var l_sqr = d.length_squared()
		if l_sqr < radius_sqr:
			# objects.push_back( n )
			objects[ n ] = sqrt( l_sqr )
			
	return objects

# :deprecated: older experiment for reference only
func get_objects_colliding( position: Vector2, shape: CollisionShape2D, candidates: Array[ Node2D ] ) -> Array[ Node2D ]:
	var circle_shape := shape.shape as CircleShape2D
	var radius := circle_shape.radius if circle_shape != null else 0.0
	var radius_sqr = radius*radius
	
	if candidates.is_empty():
		for c in %Pickups.get_children():
			var n = c as Node2D
			if n == null:
				continue
			candidates.push_back( n )
		for c in %Obstacles.get_children():
			var n = c as Node2D
			if n == null:
				continue
			candidates.push_back( n )
		
	var objects: Array[ Node2D ] = []
	
#	var printed = false
	#for c in %Pickups.get_children():
	for c in candidates:
		var n = c as Node2D
		if n == null:
			continue
			
		var s = null
		var cs = null # :TODO: collision shape of c
		if false && n.has_method( "get_picking_shape"):
			cs = n.get_picking_shape() as CollisionShape2D
			if cs != null:
				# :TODO:
				s = cs.shape

			
		if s != null:
			# :TODO:
			var s2d: Shape2D = s as Shape2D
			
			var t1 = Transform2D( n.rotation, n.position ) # :TODO: fix rotation
			var t2 = Transform2D( 0.0, position )
			
			if s2d.collide(t1, shape.shape, t2):
				objects.push_back( n )
		else:
			# var p = n.global_position
			var p = n.position
			var d = p - position
			var l_sqr = d.length_squared()
#			if !printed && l_sqr < 6773214.0:
#				print( "Checking %s - %s => %s => %f < %f" % [ p, position, d, l_sqr, radius_sqr ] )
#				printed = true
			if l_sqr < radius_sqr:
				objects.push_back( n )
			
	return objects

func ensure_unique_entity_ids() -> int:
	var children = %Pickups.get_children()
	children.append_array( %Obstacles.get_children() )
	
	var duplicate_count = 0
	var seen_ids: Dictionary[ int, int ] = {}
	
	for c in children:
		var e = c as Entity
		if e == null:
			continue
		var id = e.get_meta("fiiish_nzlo_id", 0xffff)
		if id == 0xffff:
			continue
		
		if seen_ids.has( id ):
			# seens_ids[ id ] += 1
			self._assign_next_object_id( e )
			duplicate_count += 1
		else:
			seen_ids[ id ] = 1
		
	return duplicate_count

func get_zone_offset_x() -> float:
	return self._zone_offset_x
	
func set_zone_offset_x( x: float ) -> void:
	self._zone_offset_x = x
	
func add_zone_offset_x( x: float ) -> void:
	self._zone_offset_x += x

func reset_object_ids() -> void:
	print("Reset object ids")
	self._next_object_id = 1

func _assign_next_object_id( node: Node2D ) -> int:
	if self._next_object_id >= 0xffff:
		push_warning("Too many objects")
		return 0xffff
	var id = self._next_object_id
	self._next_object_id += 1
	node.set_meta("fiiish_nzlo_id", id)
	print("Generated new object id 0x%04x" % id )
	return id
	
func ensure_object_id( node: Node2D ) -> int:
	var id = node.get_meta("fiiish_nzlo_id", 0xffff)
	if id != 0xffff:
		return id
	
	return self._assign_next_object_id( node )

func set_entity_id( node: Node2D, id: int ) -> void:
	# :TODO: avoid duplicates?
	node.set_meta("fiiish_nzlo_id", id)
	
func find_object_by_id( id: int ) -> Node2D:
	if id == 0xffff:
		push_warning("Tried to search for invalid object id 0x%04x" % id)
		return null

	for c in %Obstacles.get_children():
		var o = c as Obstacle
		if o == null:
			continue
		if id == o.get_meta("fiiish_nzlo_id", 0xffff):
			return o

	for c in %Pickups.get_children():
		var p = c as Pickup
		if p == null:
			continue
		if id == p.get_meta("fiiish_nzlo_id", 0xffff):
			return p

	return null
