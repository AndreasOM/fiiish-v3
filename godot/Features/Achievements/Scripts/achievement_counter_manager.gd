class_name AchievementCounterManager

var _version: int = 0
var _counters: Dictionary[ AchievementCounterIds.Id, int ] = {}

func reset_counters() -> void:
	self._counters.clear()

func get_version() -> int:
	return self._version
	
func set_counter( id: AchievementCounterIds.Id, value: int ) -> bool:
	var old_value = self._counters.get( id, 0 )
	if value == old_value:
		return false
	
	self._counters[ id ] = value
	self._version += 1
	# print("Set Achievement Counter %s = %d" % [ AchievementCounterIds.to_name( id ), value ])
	return true
	
func get_counter( id: AchievementCounterIds.Id ) -> int:
	return self._counters.get( id, 0 )
