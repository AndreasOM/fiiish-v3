class_name OverlayTestScript
extends Node
const OverlayFolder = "res://Textures/Overlays/"

func wait_for_key_n() -> void:
	while true:
		if Input.is_key_pressed(KEY_N):
			print("Got N")
			break
		await get_tree().process_frame
	print("Broke N loop")
	while true:
		if !Input.is_key_pressed(KEY_N):
			print("Not N")
			break
		await get_tree().process_frame
	print("Broke not N loop")
	
func run( script_manager: ScriptManager ) -> bool:
	while true:
		await script_manager.enable_overlay( "overlay-00-title_with_markers.png", "FullRect" )
		await wait_for_key_n()
		script_manager.clear_overlays()
		
		await script_manager.enable_overlay( "overlay-01-explore.png", "NW" )
		await script_manager.enable_overlay( "overlay-01-explore.png", "NE" )
		await script_manager.enable_overlay( "overlay-01-explore.png", "SE" )
		await script_manager.enable_overlay( "overlay-01-explore.png", "SW" )
		await wait_for_key_n()
		script_manager.clear_overlays()
	
	return true
