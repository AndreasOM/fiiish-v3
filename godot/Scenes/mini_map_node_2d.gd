extends Node2D
class_name MiniMapNode2D

@export var node: Node2D = null
@onready var game_scaler: GameScaler = %GameScaler

func _ready() -> void:
#	self._clone_node()
#	if self.node != null:
#		self.add_child( self.node )
	pass
	
func _clone_node() -> void:
	for c in self.get_children():
		self.remove_child( c )
		c.queue_free()
		
	if self.node != null:
		var flags = 0 
		# flags |= DuplicateFlags.DUPLICATE_SIGNALS
		# flags |= DuplicateFlags.DUPLICATE_GROUPS
		# flags |= DuplicateFlags.DUPLICATE_SCRIPTS
		flags |= DuplicateFlags.DUPLICATE_USE_INSTANTIATION
		
		var d = self.node.duplicate( flags )
		d.process_mode = Node.PROCESS_MODE_DISABLED
		self.add_child( d )
		
		self._play_tree( d )
	
func _process(delta: float) -> void:
	# self._clone_node()
	self.queue_redraw()
	pass
	
func _draw() -> void:
	# print("MiniMapNode2D _draw()")
	if self.node != null:
		# :TODO: !!!
		# var scale = (1.0/self.game_scaler.scale.y) * 0.25  * (1.0/1.0)
		# var scale = (1.0/self.game_scaler.scale.y) * 0.25  * (1.0/1.0)
		var scale = 1.0 * 0.125  * (1.0/1.0)
		
		self._draw_tree( self.node, scale, false )

func _play_tree( t: Node2D ) -> void:
	for c in t.get_children():
		var a = c as AnimatedSprite2D
		if a != null:
			a.play("default")
			
		self._play_tree( c )
		
func _draw_tree( t: Node2D, scale: float, rot180: bool ) -> void:
	if !t.visible:
		return

	if wrapf( t.rotation_degrees, 0.0, 360.0 ) == 180.0:
		rot180 = !rot180
		
	for c in t.get_children():
		#print("MiniMapNode2D child")
		if false: # :HACK:
			pass
#		elif c as Fish != null:
#			var f = c as Fish
#			# print("MiniMapNode2D - drawing fish")
#			self.draw_circle( f.global_position*scale, 50.0*scale, Color.ORANGE, false, 5.0 )
#			continue

#		elif c as Pickup != null:
#			var p = c as Pickup
#			# print("MiniMapNode2D - drawing pickup")
#			self.draw_circle( p.global_position, 15.0, Color.YELLOW, false, 3.0 )
		elif c.has_method( &"draw_minimap" ):
			c.draw_minimap( self, scale )
			continue
		elif c as Sprite2D != null:
			var s = c as Sprite2D
			var tex = s.texture
			var size = tex.get_size() #*scale
			var flip = 1.0
			#if wrapf( c.rotation_degrees, 0.0, 360.0 ) == 180.0:
			if rot180:
				flip = -1.0
			var r = Rect2( (c.global_position - 0.5*size)*scale, flip*size*scale )
			# var t2dr = Transform2D.IDENTITY.rotated( deg_to_rad( 45.0 ) )
			# r *= t2dr
			var transpose = false
			var color = Color.WHITE
			self.draw_texture_rect( tex, r, false, color, transpose )
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
			var tex = sf.get_frame_texture(anim, idx)
			# t.draw( n, self.global_position, Color.PINK )
			# n.draw_texture( t, self.global_position, Color.DODGER_BLUE )
			var size = tex.get_size()
			var flip = 1.0
			if wrapf( self.rotation_degrees, 0.0, 360.0 ) == 180.0:
				flip = -1.0
			var r = Rect2( (c.global_position - 0.5*size)*scale, flip*size*scale )
			var transpose = false
			var color = Color.WHITE
			self.draw_texture_rect( tex, r, false, color, transpose )

		if c as Node2D != null:
			self._draw_tree( c, scale, rot180 )
