extends Node
class_name GameManager

signal zone_changed
@export var movement_x: float = 240.0:
	get:
		if self._paused:
			return 0.0
		else:
			return movement_x

@export var left_boundary: float = -1200.0
@export var left_boundary_wrap_offset: float = 0	# 0=> destroy instead of wrapping

var _paused: bool = true

var _rock_a = preload("res://Scenes/Obstacles/rock_a.tscn")
var _rock_b = preload("res://Scenes/Obstacles/rock_b.tscn")
var _rock_c = preload("res://Scenes/Obstacles/rock_c.tscn")
var _rock_d = preload("res://Scenes/Obstacles/rock_d.tscn")
var _rock_e = preload("res://Scenes/Obstacles/rock_e.tscn")
var _rock_f = preload("res://Scenes/Obstacles/rock_f.tscn")
var _seaweed_e = preload("res://Scenes/Obstacles/seaweed_e.tscn")

var _next_zone: int = -1
var _zones: Array[ NewZone ] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var zones = DirAccess.get_files_at("res://Resources/Zones/")
	for zn in zones:
		var fzn = "res://Resources/Zones/%s" % zn
		var z = load( fzn )
		self._zones.push_back(z )
		
	self._next_zone = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func pause():
	self._paused = true

func resume():
	self._paused = false

func spawn_zone():
	#var xs = [ 1200.0, 1500.0, 1800.0 ]
	#var y = 410.0
	#for x in xs:
		#var o = _rock_b.instantiate()
		#o.game_manager = self
		#o.position = Vector2( x, y )
		#%Obstacles.add_child(o)

	var zone = null
	if self._next_zone >= 0 && self._next_zone < self._zones.size():
		zone = self._zones[ self._next_zone ]
		self._next_zone = -1
	else:
		zone = self._zones.pick_random()
#	if self._zone != null:
	if zone != null:
		self.zone_changed.emit( zone.name)
		for l in zone.layers:
			if l.name == "Obstacles" || l.name == "Obstacles_01":
				for obj in l.objects:
	#ROCKA           = 0xd058353c,
	#ROCKB           = 0x49516486,
	#ROCKC           = 0x3e565410,
	#ROCKD           = 0xa032c1b3,
	#ROCKE           = 0xd735f125,
	#ROCKF           = 0x4e3ca09f,
	
	#SEAWEEDA        = 0x6fe93bef,
	#SEAWEEDB        = 0xf6e06a55,
	#SEAWEEDC        = 0x81e75ac3,
	#SEAWEEDD        = 0x1f83cf60,
	#SEAWEEDE        = 0x6884fff6,
	#SEAWEEDF        = 0xf18dae4c,
	#SEAWEEDG        = 0x868a9eda,
	
					var o = null
					match obj.crc:
						0xd058353c: # ROCKA
							o = _rock_a.instantiate()
						0x49516486: #ROCKB
							o = _rock_b.instantiate()
						0x3e565410: #ROCKC
							o = _rock_c.instantiate()
						0xa032c1b3: #ROCKD
							o = _rock_d.instantiate()
						0xd735f125: #ROCKE
							o = _rock_e.instantiate()
						0x4e3ca09f: #ROCKF
							o = _rock_f.instantiate()
						0x6884fff6: #SEAWEEDE
							o = _seaweed_e.instantiate()
						_:
							print("Unhandled CRC: %08x" % obj.crc)
							
					if o != null:
						o.game_manager = self
						o.position = Vector2( obj.pos_x, obj.pos_y )
						o.rotation_degrees = obj.rotation
						%Obstacles.add_child(o)
						#print( o )
						
func cleanup():
	for o in %Obstacles.get_children():
		%Obstacles.remove_child(o)
		o.queue_free()

func goto_next_zone():
	print("Next Zone")
	self.cleanup()
	self.spawn_zone()
