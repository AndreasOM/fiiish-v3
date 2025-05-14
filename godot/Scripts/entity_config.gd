class_name EntityConfig

var entity_type: EntityTypes.Id = EntityTypes.Id.NONE
var resource: Resource = null
var name: String = ""

func _init( n: String, t: EntityTypes.Id, r: Resource ):
	name = n
	entity_type = t
	resource = r
	
