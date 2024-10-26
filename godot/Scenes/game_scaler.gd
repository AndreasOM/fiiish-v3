extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screensize =  get_viewport().size
	var scale = screensize.y/1024.0
	self.scale.x = scale
	self.scale.y = scale
	var a = screensize.x*1.0/screensize.y*1.0
	#print(a)
	position.x = 0.5 *screensize.x #0.5*960*scale # 960*scale
	position.y = 512*scale
	
