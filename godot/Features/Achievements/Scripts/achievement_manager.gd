class_name AchievementManager
extends Node

@export var game_manager: GameManager = null

var _last_version: int = 0

var _achievements: Dictionary[ String, AchievementStates.State ] = {}

func _process( _delta: float ) -> void:
	if self.game_manager == null:
		return

	var config_manager = self.game_manager.get_achievement_config_manager()
	var counter_manager = self.game_manager.get_achievement_counter_manager()
	
	var version = counter_manager.get_version()
	if version == self._last_version:
		return
	
	self._last_version = version

	# print("== Checking Achievements %d ==" % version)
	for k in config_manager.get_keys():
		var cfg = config_manager.get_config( k )
		if cfg == null:
			continue
		var state = self._achievements.get( cfg.id, AchievementStates.State.UNKNOWN )
		match state:
			AchievementStates.State.COMPLETED:
				continue
			AchievementStates.State.COLLECTED:
				continue
		# print("Checking Achievement %s" % cfg.name)
		if !self._check_condition_prereq_achievements( cfg.completion_condition, counter_manager ):
			continue
		if !self._check_condition_counters( cfg.completion_condition, counter_manager):
			continue
		print("Completed Achievement %s" % cfg.name)
		self._achievements[ cfg.id ] = AchievementStates.State.COMPLETED
		# Events.broadcast_global_message( "Completed: %s" % cfg.name )
		Events.broadcast_achievement_completed( cfg.id )
			
func _check_condition_prereq_achievements( condition: AchievementCondition, counter_manager: AchievementCounterManager ) -> bool:
	for id in condition.prereq_achievement_ids:
		var s = self._achievements.get( id, AchievementStates.State.UNKNOWN )
		match s:
			AchievementStates.State.COMPLETED:
				continue
			AchievementStates.State.COLLECTED:
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
		var s = self._achievements.get( k, AchievementStates.State.UNKNOWN )
		if s == AchievementStates.State.COMPLETED:
			r.push_back( k )
			
	return r

func reset_achievements() -> void:
	self._achievements.clear()

func mark_achievement_completed( id: String ) -> void:
	self._achievements[ id ] = AchievementStates.State.COMPLETED
	
func mark_achievement_collected( id: String ) -> void:
	self._achievements[ id ] = AchievementStates.State.COLLECTED

func collect_achievement( id: String ) -> bool:
	var s = self._achievements.get( id, AchievementStates.State.UNKNOWN )
	match s:
		AchievementStates.State.UNKNOWN:
			return false
		AchievementStates.State.COLLECTED:
			return false
		AchievementStates.State.COMPLETED:
			self._achievements[ id ] = AchievementStates.State.COLLECTED
			return false
			
	return false
	
func get_achievement_state( id: String ) -> AchievementStates.State:
	return self._achievements.get( id, AchievementStates.State.UNKNOWN )
	
