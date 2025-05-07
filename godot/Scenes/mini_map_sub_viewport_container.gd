@tool

class_name MiniMapSubViewportContainer
extends SubViewportContainer

@export var source: CanvasItem = null
@export var source_world: World2D = null : set = _set_source_world
@onready var sub_viewport: SubViewport = %SubViewport


func _set_source_world( v: World2D ) -> void:
	source_world = v
	self.sub_viewport.world_2d = v
	
func _ready() -> void:
	if self.source != null:
		self.sub_viewport.world_2d = source.get_world_2d()
		# sub_viewport.connect("size_changed", _fix_size)
	elif self.source_world != null:
		self.sub_viewport.world_2d = self.source_world

	self.sub_viewport.size_changed.connect(_fix_size)
	_fix_size()

func _fix_size() -> void:
	# print( "MiniMap _fix_size")
	var size = self.sub_viewport.size
	var scale = 1080.0/size.y
	
	self.sub_viewport.size_2d_override = size * scale
