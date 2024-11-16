extends Object
class_name SkillConfig

var skill_id: SkillIds.Id = SkillIds.Id.NONE
var name: String = "[UNKNOWN]"
var levels: Dictionary = {}

func _init( skill_id: SkillIds.Id, name: String ) -> void:
	self.skill_id = skill_id
	self.name = name
	
func add_level( level: int, config: SkillLevelConfig ):
	self.levels[ level ] = config
	
func get_level( level: int ) -> SkillLevelConfig:
	return self.levels.get( level )


func get_upgrade_levels() -> int:
	var r = 0
	for l in levels.keys():
		if l != 0:
			r += 1
	
	return r
