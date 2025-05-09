extends Object
class_name SkillConfig

var _skill_id: SkillIds.Id = SkillIds.Id.NONE
var name: String = "[UNKNOWN]"
var levels: Dictionary = {}

func _init( id: SkillIds.Id, skill_name: String ) -> void:
	self._skill_id = id
	self.name = skill_name
	
func skill_id() -> SkillIds.Id:
	return self._skill_id

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
