extends Control

signal zoom_changed
signal goto_next_zone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_value_changed(value: float) -> void:
	self.zoom_changed.emit( value )


func _on_button_small_pressed() -> void:
	%ZoomSlider.value = 0.3


func _on_button_medium_pressed() -> void:
	%ZoomSlider.value = 0.6


func _on_button_normal_pressed() -> void:
	%ZoomSlider.value = 1.0


func _on_game_zone_changed( name: String ) -> void:
	print( "Zone: ", name )
	%CurrentZoneLabel.text = name
	pass # Replace with function body.


func _on_next_zone_button_pressed() -> void:
	self.goto_next_zone.emit()


func _on_debug_collision_check_button_toggled(toggled_on: bool) -> void:
	# self.get_tree().set_debug_collisions_hint(toggled_on)
	# :(
	pass
