class_name ZoneEditorCommandHandler

signal command_history_size_changed( history_size: int, future_size: int )

var _zone_manager: ZoneManager

var _command_history: Array[ ZoneEditorCommand ] = []
var _command_future: Array[ ZoneEditorCommand ] = []

func _init( zone_manager: ZoneManager ) -> void:
	self._zone_manager = zone_manager
	
func clear_history() -> void:
	self._command_history.clear()
	self._command_future.clear()
	self.command_history_size_changed.emit( 0, 0 )
	
func command_history_size() -> int:
	return self._command_history.size()

func undo() -> bool:
	if _command_history.is_empty():
		return false
	var command = _command_history.pop_back()
	var r = command.undo( self._zone_manager )
	self._command_future.push_back( command )
	self.command_history_size_changed.emit( self._command_history.size(), self._command_future.size() )
	return r

func redo() -> bool:
	if _command_future.is_empty():
		return false
	var command = _command_future.pop_back()
	var r = command.run( self._zone_manager )
	self._command_history.push_back( command )
	self.command_history_size_changed.emit( self._command_history.size(), self._command_future.size() )
	return r

func add_command( command: ZoneEditorCommand ) -> void:
	if command.run( self._zone_manager ):
		self._command_future.clear()
		self._command_history.push_back( command )
		self.command_history_size_changed.emit( self._command_history.size(), self._command_future.size() )
	
func add_command_delete( node: Node2D ) -> void:
	var node_id = self._zone_manager.ensure_object_id( node )
	var command = ZoneEditorCommandDelete.new( node_id )
	self.add_command( command )

func add_command_move( node: Node2D, move: Vector2, rotate_degrees: float ) -> void:
	var node_id = self._zone_manager.ensure_object_id( node )
	var command = ZoneEditorCommandMove.new( node_id, move, rotate_degrees )
	self.add_command( command )

func add_command_spawn( crc: int, position: Vector2, rotate_degrees: float ) -> void:
	var command = ZoneEditorCommandSpawn.new( crc, position, rotate_degrees )
	self.add_command( command )

class ZoneEditorCommand:
	func run(zone_manager: ZoneManager) -> bool:
		return false
	
	func undo(zone_manager: ZoneManager) -> bool:
		return false
	
class ZoneEditorCommandDelete:
	extends ZoneEditorCommand

	var _node_id: int
	var _nzlo: NewZoneLayerObject = null
	var _zone_offset_x: float = 0.0
	
	func _init( id: int ) -> void:
		self._node_id = id

	func run(zone_manager: ZoneManager) -> bool:
		var node = zone_manager.find_object_by_id( self._node_id )
		if node == null:
			return false
		var offset_x = 0.0 # :TODO: ???
		var nzlo = zone_manager.create_new_zone_layer_object_from_node( node, offset_x)
		if nzlo == null:
			push_warning("Tried to delete object that can't be converted to NewZoneLayerObject")
			return false
		self._nzlo = nzlo
		# self._zone_offset_x = zone_manager.get_zone_offset_x()
		self._zone_offset_x = zone_manager.current_zone_progress
		var p = node.get_parent()
		if p != null:
			p.remove_child( node )
		node.queue_free()
		return true
		
	func undo(zone_manager: ZoneManager) -> bool:
		if self._nzlo == null:
			push_warning( "Tried to undo delete of object without NewZoneLayerObject")
			return false
			
		# var zone_offset_x = zone_manager.get_zone_offset_x()
		var zone_offset_x = zone_manager.current_zone_progress
		var spawn_offset = self._zone_offset_x - zone_offset_x
		return zone_manager.spawn_new_zone_layer_object( self._nzlo, spawn_offset )

class ZoneEditorCommandMove:
	extends ZoneEditorCommand

	# var _node: Node2D
	var _node_id: int
	var _move: Vector2
	var _rotate_degrees: float
	
	func _init( id: int, m: Vector2, rotate_degrees: float ) -> void:
		#self._node = n
		self._node_id = id
		self._move = m
		self._rotate_degrees = rotate_degrees

	func run(zone_manager: ZoneManager) -> bool:
		var node = zone_manager.find_object_by_id( self._node_id )
		if node == null:
			return false
			
		node.position += self._move
		node.rotation_degrees += self._rotate_degrees
		return true
		
	func undo(zone_manager: ZoneManager) -> bool:
		var node = zone_manager.find_object_by_id( self._node_id )
		if node == null:
			return false
		node.position -= self._move
		node.rotation_degrees -= self._rotate_degrees
		return true

class ZoneEditorCommandSpawn:
	extends ZoneEditorCommand

	var _crc: int
	var _position: Vector2
	var _rotate_degrees: float
	var _node_id: int = 0xffff
	
	func _init( crc: int, position: Vector2, rotate_degrees: float ) -> void:
		#self._node = n
		self._crc = crc
		self._position = position
		self._rotate_degrees = rotate_degrees

	func run(zone_manager: ZoneManager) -> bool:
		var spawn_offset = 0.0
		var node = zone_manager.spawn_object_from_crc( self._crc, self._position, self._rotate_degrees, spawn_offset)
		if node == null:
			return false
		
		if self._node_id == 0xffff:
			self._node_id = zone_manager.ensure_object_id( node )
		else:
			zone_manager.set_entity_id( node, self._node_id )
		return true
		
	func undo(zone_manager: ZoneManager) -> bool:
		if self._node_id == 0xffff:
			return false
		var node = zone_manager.find_object_by_id( self._node_id )
		if node == null:
			return false
		node.queue_free()
		return true
