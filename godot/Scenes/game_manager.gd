extends Node
class_name GameManager

@export var movement_x: float = 240.0:
	get:
		if self._paused:
			return 0.0
		else:
			return movement_x

var _paused: bool = true

var _rock_a = preload("res://Scenes/Obstacles/rock_a.tscn")
var _rock_b = preload("res://Scenes/Obstacles/rock_b.tscn")
var _rock_c = preload("res://Scenes/Obstacles/rock_c.tscn")
var _rock_d = preload("res://Scenes/Obstacles/rock_d.tscn")
var _rock_e = preload("res://Scenes/Obstacles/rock_e.tscn")
var _rock_f = preload("res://Scenes/Obstacles/rock_f.tscn")

var _zone: NewZone = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._zone = load("res://Resources/Zones/0000_ILoveFiiish.nzne")
	print("", self._zone, self._zone.name )
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

	if self._zone != null:
		for l in self._zone.layers:
			if l.name == "Obstacles" || l.name == "Obstacles_01":
				for obj in l.objects:
	#ROCKA           = 0xd058353c,
	#ROCKB           = 0x49516486,
	#ROCKC           = 0x3e565410,
	#ROCKD           = 0xa032c1b3,
	#ROCKE           = 0xd735f125,
	#ROCKF           = 0x4e3ca09f,
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
