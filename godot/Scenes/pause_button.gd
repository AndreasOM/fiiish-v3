extends TextureButton

@export var texture_a: Texture2D = null
@export var texture_b: Texture2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.texture_normal = texture_a

func set_a( is_a: bool ) -> void:
	if is_a:
		self.texture_normal = texture_a
	else:
		self.texture_normal = texture_b

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
