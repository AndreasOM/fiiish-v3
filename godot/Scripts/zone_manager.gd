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

func _process(delta: float) -> void:
	self.current_zone_progress += self.game_manager.movement_x * delta
	if self._current_zone != null:
		if self.current_zone_progress >= self._current_zone.width:
			self.spawn_zone()

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

func spawn_zone():
	#var xs = [ 1200.0, 1500.0, 1800.0 ]
	#var y = 410.0
	#for x in xs:
		#var o = _rock_b.instantiate()
		#o.game_manager = self
		#o.position = Vector2( x, y )
		#%Obstacles.add_child(o)

	var zone = null
	var next_zone = self._zone_config_manager.pop_next_zone()
		
	if next_zone >= 0 && next_zone < self._zone_config_manager.zone_count():
		zone = self._zone_config_manager.get_zone( next_zone )
	else:
		zone = self._pick_next_zone()
#	if self._zone != null:
	if zone != null:
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
						o.game_manager = self.game_manager
						o.position = Vector2( obj.pos_x + self.game_manager.zone_spawn_offset, obj.pos_y )
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
