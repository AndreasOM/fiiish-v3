class_name MiniMapDialog
extends Dialog


@export var game: Game = null
@onready var mini_map_sub_viewport_container: MiniMapSubViewportContainer = %MiniMapSubViewportContainer

func _ready() -> void:
	self._update_viewport()
	
func set_game( game: Game ) -> void:
	self.game = game
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
	
func open( duration: float):
	fade_in( duration )

func close( duration: float):
	fade_out( duration )

func toggle( duration: float ):
	toggle_fade( duration )

func toggle_fade( duration: float ):
	%FadeablePanelContainer.toggle_fade( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )


func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()
