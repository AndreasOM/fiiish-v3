@tool

extends PanelContainer

@export var source: CanvasItem = null
@onready var sub_viewport: SubViewport = %SubViewport


func _ready() -> void:
	self.sub_viewport.world_2d = source.get_world_2d()
	# sub_viewport.connect("size_changed", _fix_size)
	sub_viewport.size_changed.connect(_fix_size)
	_fix_size()

func _fix_size() -> void:
	print( "MiniMap _fix_size")
	var size = sub_viewport.size
	var scale = 1080.0/size.y
	
	sub_viewport.size_2d_override = size * scale
