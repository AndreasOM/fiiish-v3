extends Object
class_name SkillLevelConfig

# var skill_effect_id: SkillEffectIds.Id
# var level: int

# cost in skillpoints
var cost: int
var effects: Dictionary = {} # [ SkillEffectIds.Id, float ]


func _init( cost: int ):
	self.cost = cost

func add_effect( id: SkillEffectIds.Id, value: float) -> SkillLevelConfig:
	self.effects[ id ] = value	
	return self
	
func get_effect( id: SkillEffectIds.Id, default: float ) -> float:
	var e = effects.get( id )
	if e == null:
		return default
		
	return e

func get_effect_ids() -> Array:
	return effects.keys()
	
