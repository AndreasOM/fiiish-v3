class_name EntityConfig
extends Resource

@export var name: String = ""
@export var entity_id: EntityId.Id = EntityId.Id.INVALID
@export var entity_type: EntityTypes.Id = EntityTypes.Id.NONE
@export var resource: PackedScene = null

#func _init( n: String, t: EntityTypes.Id, r: PackedScene ):
#	name = n
#	entity_type = t
#	resource = r
	
