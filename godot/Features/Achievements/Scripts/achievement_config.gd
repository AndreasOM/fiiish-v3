class_name AchievementConfig
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var icon: Texture2D = null
@export var completion_condition: AchievementCondition = null

@export var reward_coins: int = 0
@export var reward_skill_points: int = 0
@export var reward_extra: Array[ String ] = []
