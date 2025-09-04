class_name EntitySelectButton
extends TextureButton

signal entity_changed( id: EntityId.Id )

@onready var label: Label = $Label

var entity_config_manager: EntityConfigManager = null : set = set_entity_config_manager

var _index: int = 0

func set_entity_config_manager( ecm: EntityConfigManager ) -> void:
	entity_config_manager = ecm

func _on_pressed( increment: int ) -> void:
	var old_index = self._index
	self._index += increment
	
	while self._index != old_index:
		var id = self.entity_config_manager.get_id_by_index( self._index )
		if id == EntityId.Id.INVALID:
			self._index = 0
			continue
			# id = self.entity_config_manager.get_id_by_index( self._index )
			
		var ec = self.entity_config_manager.get_entry( id )
		if ec.entity_type == EntityTypes.Id.AREA:
			self._index += increment
			if self._index < 0:
				self._index = 0 # :TODO add wrap around later
			continue

		# self.label.text = ec.name
		# print("id: 0x%08x" % id)
		# self.label.text = "0x%08x" % id
		self.entity_changed.emit( id )
		break
			
