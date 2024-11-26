class_name SkillEffectSet


# var _magnet_range_factor: float = 1.0

var _skill_effects: Dictionary = {}

func apply_skills( player: Player, scm: SkillConfigManager ):
	_skill_effects.clear()
	for skill_id in scm.get_skill_ids():
		var skill_level = player.get_skill_level( skill_id )
		var skill_level_config = scm.get_skill_level_config( skill_id, skill_level )
		if skill_level_config != null:
			for skill_effect_id in skill_level_config.get_effect_ids():
				var effect_value = skill_level_config.get_effect( skill_effect_id, 1.0 )
				if _skill_effects.has( skill_effect_id ):
					push_warning("Overlapping skill effects not handled yet. Last value will be used!")
				_skill_effects[ skill_effect_id ] = effect_value


func get_value( skill_effect_id: SkillEffectIds.Id, default: float ) -> float:
	return _skill_effects.get( skill_effect_id, default )
