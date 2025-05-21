class_name AchievementCondition
extends Resource

@export var prereq_achievement_ids: Array[ String ] = []
@export var prereq_counters: Dictionary[ AchievementCounterIds.Id, int ] = {}
