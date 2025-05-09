extends Control

@export var game: Game = null

signal zoom_changed
signal goto_next_zone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%DebugCamerCheckButton.button_pressed = %CameraDebugPanel.visible
	Events.zone_changed.connect( _on_zone_changed )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.game !=	null:
		var game_manager = self.game.get_game_manager()
		if game_manager != null:
			var zx = game_manager.get_current_zone_progress()
			%CurrentZoneProgressLabel.text = "%5.2f" % zx
			var zw = game_manager.get_current_zone_width()
			%CurrentZoneWidthLabel.text = "%5.2f" % zw
			%CurrentZoneProgressBar.value = ( zx/zw ) * 100.0 
			# print( "%5.2f" % ( zx/zw ) )
			var coins = game_manager.coins()
			%CoinValueLabel.text = "%d" % coins
		pass
	pass


func _on_h_slider_value_changed(value: float) -> void:
	self.zoom_changed.emit( value )
	self.recalc_camera_debug_panel()


func recalc_camera_debug_panel():
	var z = %ZoomSlider.value
	%CameraDebugPanel.scale = Vector2( z, z )
	
	
	
	# | ---x--- |
	# | ..-x-.. |
	# ??
	# ?? = 0.5 window width - 0.5 scaled panel width
	# ?? = 0.5 ( window width - scaled panel width )
	# ?? = 0.5 ( panel width - scale * panel width )
	# ?? = 0.5 ( 1.0 * panel width - scale * panel width )
	# ?? = 0.5 * ( ( 1.0 - scale ) * panel width )
	## above math is resulting in the wrong result
	#var offset_x = 0.5* (( 1.0 - z ) * %CameraDebugPanel.size.x)
	# var offset_x = (( 1.0 - z ) * %CameraDebugPanel.size.x)
	var offset_x = 0.5 * %CameraDebugPanel.size.x
	var offset_y = 0.5 * %CameraDebugPanel.size.y
	%CameraDebugPanel.pivot_offset.x = offset_x
	%CameraDebugPanel.pivot_offset.y = offset_y

func _on_button_tiny_pressed() -> void:
	%ZoomSlider.value = 0.025
		
func _on_button_small_pressed() -> void:
	%ZoomSlider.value = 0.25


func _on_button_medium_pressed() -> void:
	%ZoomSlider.value = 0.5


func _on_button_normal_pressed() -> void:
	%ZoomSlider.value = 1.0


func _on_zone_changed( zone: NewZone ) -> void:
	print( "Zone: ", zone.name )
	%CurrentZoneLabel.text = zone.name
	pass # Replace with function body.


func _on_next_zone_button_pressed() -> void:
	self.goto_next_zone.emit()


func _on_debug_collision_check_button_toggled(_toggled_on: bool) -> void:
	# self.get_tree().set_debug_collisions_hint(toggled_on)
	# :(
	pass


func _on_debug_camer_check_button_toggled(toggled_on: bool) -> void:
	%CameraDebugPanel.visible = toggled_on


func _on_button_pressed() -> void:
	print("Unity")
