class_name AchievementManager
extends Node

enum AchievementState {
	UNKNOWN,
	COMPLETED
}

@export var game_manager: GameManager = null

var _last_version: int = 0

var _achievements: Dictionary[ String, AchievementState ] = {}

func _process( _delta: float ) -> void:
	if self.game_manager == null:
		return

	var config_manager = self.game_manager.get_achievement_config_manager()
	var counter_manager = self.game_manager.get_achievement_counter_manager()
	
	var version = counter_manager.get_version()
	if version == self._last_version:
		return
	
	self._last_version = version

	for k in config_manager.get_keys():
		var cfg = config_manager.get_config( k )
		if cfg == null:
			continue
		var state = self._achievements.get( cfg.name, AchievementState.UNKNOWN )
		if state == AchievementState.COMPLETED:
			continue
		print("Checking Achievement %s" % cfg.name)
		if self._check_condition_counters( cfg.completion_conditions, counter_manager):
			print("Completed Achievement %s" % cfg.name)
			self._achievements[ cfg.name ] = AchievementState.COMPLETED
			
	
func _check_condition_counters( condition: AchievementCondition, counter_manager: AchievementCounterManager ) -> bool:
	for id in condition.prereq_counters.keys():
		var needed_value = condition.prereq_counters.get( id, null)
		if needed_value == null:
			continue
		var value = counter_manager.get_counter( id )
		if needed_value > value:
			return false
	return true	
