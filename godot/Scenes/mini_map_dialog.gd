class_name MiniMapDialog
extends FiiishDialog


@export var game: Game = null
@onready var mini_map_sub_viewport_container: MiniMapSubViewportContainer = %MiniMapSubViewportContainer

func _ready() -> void:
	super._ready()
	self._update_viewport()
	
func set_game( g: Game ) -> void:
	self.game = g
	self._update_viewport()

func _update_viewport() -> void:
	if self.mini_map_sub_viewport_container == null:
		return
		
	if self.game == null:
		return
		
	var world_2d := game.get_world_2d()
	if world_2d == null:
		return
		
	self.mini_map_sub_viewport_container.source_world = world_2d
