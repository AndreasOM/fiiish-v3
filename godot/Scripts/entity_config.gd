class_name EntityConfig

const EntityType = preload("res://Scripts/entity_type.gd").EntityType

var entity_type: EntityType = EntityType.NONE
var resource: Resource = null

func _init( t: EntityType, r: Resource ):
	entity_type = t
	resource = r
	
