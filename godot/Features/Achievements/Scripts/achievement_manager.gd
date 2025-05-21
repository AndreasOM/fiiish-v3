class_name AchievementManager
extends Node

enum AchievementState {
	UNKNOWN,
	COMPLETED,
	COLLECTED,
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

	print("== Checking Achievements %d ==" % version)
	for k in config_manager.get_keys():
		var cfg = config_manager.get_config( k )
		if cfg == null:
			continue
		var state = self._achievements.get( cfg.id, AchievementState.UNKNOWN )
		match state:
			AchievementState.COMPLETED:
				continue
			AchievementState.COLLECTED:
				continue
		print("Checking Achievement %s" % cfg.name)
		if !self._check_condition_prereq_achievements( cfg.completion_condition, counter_manager ):
			continue
		if !self._check_condition_counters( cfg.completion_condition, counter_manager):
			continue
		print("Completed Achievement %s" % cfg.name)
		self._achievements[ cfg.id ] = AchievementState.COMPLETED
			
func _check_condition_prereq_achievements( condition: AchievementCondition, counter_manager: AchievementCounterManager ) -> bool:
	for id in condition.prereq_achievement_ids:
		var s = self._achievements.get( id, AchievementState.UNKNOWN )
		match s:
			AchievementState.COMPLETED:
				continue
			AchievementState.COLLECTED:
				continue
		return false
	return true

func _check_condition_counters( condition: AchievementCondition, counter_manager: AchievementCounterManager ) -> bool:
	for id in condition.prereq_counters.keys():
		var needed_value = condition.prereq_counters.get( id, null)
		if needed_value == null:
			continue
		var value = counter_manager.get_counter( id )
		if needed_value > value:
			return false
	return true	

func get_completed_achievments() -> Array[ String ]:
	var r: Array[ String ] = []
	
	for k in self._achievements.keys():
		var s = self._achievements.get( k, AchievementState.UNKNOWN )
		if s == AchievementState.COMPLETED:
			r.push_back( k )
			
	return r


func mark_achievement_collected( id: String ) -> void:
	self._achievements[ id ] = AchievementState.COLLECTED

func collect_achievement( id: String ) -> bool:
	var s = self._achievements.get( id, AchievementState.UNKNOWN )
	match s:
		AchievementState.UNKNOWN:
			return false
		AchievementState.COLLECTED:
			return false
		AchievementState.COMPLETED:
			self._achievements[ id ] = AchievementState.COLLECTED
			return false
			
	return false
	
	
