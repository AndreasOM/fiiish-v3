extends Node2D

signal zone_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_debug_ui_zoom_changed( value: float ) -> void:
	self.scale.x = value
	self.scale.y = value


func _on_game_manager_zone_changed( name: String ) -> void:
	self.zone_changed.emit( name )


func _on_debug_ui_goto_next_zone() -> void:
	%GameManager.goto_next_zone()
