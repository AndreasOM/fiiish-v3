class_name Entity
extends Node2D

@export var game_manager: GameManager = null


func _process(_delta: float) -> void:
	if self.game_manager != null:
		var m = self.game_manager.movement
		self.transform.origin.x -= m.x
