class_name EntitySelectButton
extends TextureButton

signal entity_changed( id: EntityId.Id )

@onready var label: Label = $Label

@export var increment: int = 1

var entity_config_manager: EntityConfigManager = null : set = set_entity_config_manager

var _selectable_index: int = 0

var _selectable_indices: Array[ int ] = []

func set_entity_config_manager( ecm: EntityConfigManager ) -> void:
	entity_config_manager = ecm
	
	var i = 0
	self._selectable_indices.clear()
	
	while true:
		var id = self.entity_config_manager.get_id_by_index( i )
		if id == EntityId.Id.INVALID:
			break
			
		var ec = self.entity_config_manager.get_entry( id )
		if ec.entity_type != EntityTypes.Id.AREA:
			self._selectable_indices.push_back( i )
		
		i += 1

func set_current_id( id: EntityId.Id ) -> void:
	var n = self._selectable_indices.size()
	for si in range(n):
		var index = self._selectable_indices[ si ]
		var id2 = self.entity_config_manager.get_id_by_index( index )
		if id == id2:
			self._selectable_index = si
			var next_selectable_index = ( self._selectable_index + n + self.increment ) % n
			var index2 = self._selectable_indices[ next_selectable_index ]
			var next_selectable_id = self.entity_config_manager.get_id_by_index( index2 )
			var ec = self.entity_config_manager.get_entry( next_selectable_id )
			
			self.label.text = "%+d\n%s" % [ self.increment, ec.name ]
#			print("! new next_selectable_index %d (%d)" % [ next_selectable_index, self.increment ] )

			return
			
	push_warning( "Tried to select ID %d which is not found in ECM" % id )
		
func _on_pressed() -> void:
	if self.increment == 0:
		return

   	
	var n = self._selectable_indices.size()
	var selectable_index = ( self._selectable_index + n + self.increment ) % n
#	print("! %d + %d => %d (of %d)" % [self._selectable_index, self.increment, selectable_index, n ])
	var index = self._selectable_indices[ selectable_index ]
	
	var id = self.entity_config_manager.get_id_by_index( index )
	var ec = self.entity_config_manager.get_entry( id )
	self.entity_changed.emit( id )
