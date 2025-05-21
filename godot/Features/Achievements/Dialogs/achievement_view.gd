extends Control
class_name AchievementView

@onready var achievement_container: GridContainer = %AchievementContainer

var _element = preload("res://Features/Achievements/achievement_element.tscn")

func update_achievements( achievement_manager: AchievementManager, achievement_config_manager: AchievementConfigManager ) -> void:
	for c in self.achievement_container.get_children():
		c.queue_free()
	
	for ack in achievement_config_manager.get_keys():
		var ac = achievement_config_manager.get_config( ack )
		if ac == null:
			continue
		
		var e = self._element.instantiate() as AchievementElement
		if e == null:
			continue
		e.config = ac
		var s = achievement_manager.get_achievement_state( ack )
		e.state = s
		self.achievement_container.add_child( e )
