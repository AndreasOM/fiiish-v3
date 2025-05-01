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
		var scale = self.game_scaler.scale.y
		self._draw_tree( self.node, scale )

func _play_tree( t: Node2D ) -> void:
	for c in t.get_children():
		var a = c as AnimatedSprite2D
		if a != null:
			a.play("default")
			
		self._play_tree( c )
		
func _draw_tree( t: Node2D, scale: float ) -> void:
	for c in t.get_children():
		#print("MiniMapNode2D child")
		if c as Fish != null:
			var f = c as Fish
			# print("MiniMapNode2D - drawing fish")
			self.draw_circle( f.global_position, 50.0, Color.ORANGE, false, 5.0 )

#		elif c as Pickup != null:
#			var p = c as Pickup
#			# print("MiniMapNode2D - drawing pickup")
#			self.draw_circle( p.global_position, 15.0, Color.YELLOW, false, 3.0 )
		elif c.has_method( &"draw_minimap" ):
			c.draw_minimap( self, scale )
			
		self._draw_tree( c, scale )
