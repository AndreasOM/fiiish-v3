class_name EntityConfig

var entity_type: EntityTypes.Id = EntityTypes.Id.NONE
var resource: Resource = null

func _init( t: EntityTypes.Id, r: Resource ):
	entity_type = t
	resource = r
	
