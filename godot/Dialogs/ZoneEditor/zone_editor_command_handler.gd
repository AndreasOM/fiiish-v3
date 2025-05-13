class_name ZoneEditorCommandHandler

var _zone_manager: ZoneManager

var _command_history: Array[ ZoneEditorCommand ] = []

func _init( zone_manager: ZoneManager ):
	self._zone_manager = zone_manager
	
func command_history_size() -> int:
	return self._command_history.size()

func undo() -> bool:
	if _command_history.is_empty():
		return false
	var command = _command_history.pop_back()
	return command.undo( self._zone_manager )

func add_command( command: ZoneEditorCommand ) -> void:
	if command.run( self._zone_manager ):
		self._command_history.push_back( command )
	
func add_command_delete( node: Node2D ) -> void:
	node.queue_free()	# :HACK:
	var command = ZoneEditorCommandDelete.new( node )
	self.add_command( command )

class ZoneEditorCommand:
	func run(zone_manager: ZoneManager) -> bool:
		return false
	
	func undo(zone_manager: ZoneManager) -> bool:
		return false
	
class ZoneEditorCommandDelete:
	extends ZoneEditorCommand

	var _node: Node2D
	var _nzlo: NewZoneLayerObject = null
	var _zone_offset_x: float = 0.0
	
	func _init( n: Node2D ):
		self._node = n

	func run(zone_manager: ZoneManager) -> bool:
		if self._node != null:
			var offset_x = 0.0 # :TODO:
			var nzlo = zone_manager.create_new_zone_layer_object_from_node( self._node, offset_x)
			if nzlo == null:
				push_warning("Tried to delete object that can't be converted to NewZoneLayerObject")
				return false
			self._nzlo = nzlo
			# self._zone_offset_x = zone_manager.get_zone_offset_x()
			self._zone_offset_x = zone_manager.current_zone_progress
			self._node.queue_free()
		return true
		
	func undo(zone_manager: ZoneManager) -> bool:
		if self._nzlo == null:
			push_warning( "Tried to undo delete of object without NewZoneLayerObject")
			return false
			
		# var zone_offset_x = zone_manager.get_zone_offset_x()
		var zone_offset_x = zone_manager.current_zone_progress
		var spawn_offset = self._zone_offset_x - zone_offset_x
		return zone_manager.spawn_new_zone_layer_object( self._nzlo, spawn_offset )
