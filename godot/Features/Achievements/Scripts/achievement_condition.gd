class_name AchievementCondition
extends Resource

@export var prereq_achievement_id: String = ""
@export var prereq_counters: Dictionary[ AchievementCounterIds.Id, int ] = {}
