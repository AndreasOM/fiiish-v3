class_name Entity
extends Node2D

@export var game_manager: GameManager = null
var entity_type: EntityTypes.Id = EntityTypes.Id.NONE


func _process(_delta: float) -> void:
	if self.game_manager != null:
		var m = self.game_manager.movement
		self.transform.origin.x -= m.x
