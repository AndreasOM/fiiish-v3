extends Node2D

var game_manager: GameManager = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var as2d = self.get_node_or_null("%AnimatedSprite2D")
	if as2d != null:
		as2d.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if self.game_manager != null:
		var mx = self.game_manager.movement_x
		self.transform.origin.x -= mx * delta
		if position.x < self.game_manager.left_boundary:
			var wo = self.game_manager.left_boundary_wrap_offset
			if wo > 0:
				position.x += wo
			else:
				queue_free()

func draw_minimap( n: Node2D, scale: float ) -> void:
	for c in self.get_children():
		if c as Sprite2D != null:
			var s = c as Sprite2D
			var t = s.texture
			var size = t.get_size()*scale
			var flip = 1.0
			if wrapf( self.rotation_degrees, 0.0, 360.0 ) == 180.0:
				flip = -1.0
			var r = Rect2( c.global_position - 0.5*size, flip*size )
			# var t2dr = Transform2D.IDENTITY.rotated( deg_to_rad( 45.0 ) )
			# r *= t2dr
			var transpose = false
			n.draw_texture_rect( t, r, false, Color( 0.8, 0.8, 0.2, 0.95 ), transpose )
			#var rd = n.rotation_degrees
			#n.rotation_degrees += 45
			#n.draw_texture(t, self.global_position, Color.YELLOW )
			#n.rotation_degrees = rd
			# t.draw( n, self.global_position, Color.PINK )
			# t.draw( n, Vector2.ZERO, Color.PINK )
		elif c as AnimatedSprite2D != null:
			var s = c as AnimatedSprite2D
			var anim = s.animation
			var idx = s.frame
			var sf = s.sprite_frames
			var t = sf.get_frame_texture(anim, idx)
			# t.draw( n, self.global_position, Color.PINK )
			# n.draw_texture( t, self.global_position, Color.DODGER_BLUE )
			var size = t.get_size()*scale
			var flip = 1.0
			if wrapf( self.rotation_degrees, 0.0, 360.0 ) == 180.0:
				flip = -1.0
			var r = Rect2( self.global_position - 0.5*size + Vector2( 3.0, 0.0 ), flip*size )
			var transpose = false
			n.draw_texture_rect( t, r, false, Color( 0.2, 0.8, 0.8, 0.75 ), transpose )
			
			
	#if t != null:
	#	n.draw_texture(t, self.global_position )
	
	
	
	
	
	
	
	
	
	
	
	
	
