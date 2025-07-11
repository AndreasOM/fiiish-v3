class_name ScriptManager
extends Node

@onready var game: Game = %Game

const OverlayFolder = "res://Textures/Overlays/"

var _screenshot_prefix: String = ""
var _screenshot_counter: int = 0

var _overlays: Dictionary[ int, WindowAlignedSprite2D ] = {}
var _next_overlay_id: int = 1

func wait_for_game_state( state: Game.State ) -> void:
	while self.game.get_state() != state:
		print( "game state %d != %d" % [ self.game.get_state(), state ] )
		await self.game.state_changed
		
#	return

func wait_for_zone_name( n: String ) -> void:
	while self.game.zone_manager.get_current_zone_name() != n:
		await get_tree().process_frame

func wait_for_zone_progress( x: float ) -> void:
	while self.game.zone_manager.current_zone_progress < x:
		await get_tree().process_frame
		
	print( "MarketingScreenshot progress %f" % self.game.zone_manager.current_zone_progress)
		
func set_fish_target_height_range( min_h: float, max_h: float ) -> void:
	self.game.fish_manager.set_target_height_range( min_h, max_h )
	
func swim_down() -> void:
	var event = InputEventAction.new()
	event.action = "swim_down"
	event.pressed = true
	Input.parse_input_event(event)	

func abort_swim() -> void:
	self.game.abort_swim()
	
func clear_next_zones() -> void:
	self.game.get_game_manager().get_zone_config_manager().clear_next_zones()
	
func push_next_zone_by_name( n: String ) -> void:
	self.game.get_game_manager().get_zone_config_manager().push_next_zone_by_name( n )

func set_screenshot_prefix( prefix: String ) -> void:
	self._screenshot_prefix = prefix
	
func reset_screenshot_counter() -> void:
	self._screenshot_counter = 0
	
func take_screenshot( filename: String ) -> void:
	var full_filename = "%s-%04d-%s.png" % [ self._screenshot_prefix, self._screenshot_counter, filename ]
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	match image.save_png(full_filename):
		OK:
			pass
		var o:
			print("MarketingScreenshot - Error saving screenshot", o)
	print("MarketingScreenshot - screenshot saved to %s" % full_filename)
	self._screenshot_counter += 1

func clear_overlays() -> void:
	for e in self._overlays.values():
		var was: WindowAlignedSprite2D = e
		if was != null:
			was.queue_free()
	self._overlays.clear()

func enable_overlay( imagefile: String, direction: String ) -> int:
#	if self._overlay != null:
#		self._overlay.queue_free()

	var p = "%s/%s" % [ OverlayFolder, imagefile ]
	var image = Image.load_from_file( p )
	if image == null:
		push_warning("Couldn't load image %s" % p )
		return 0

	var sp = WindowAlignedSprite2D.new()
	var texture = ImageTexture.create_from_image(image)
	sp.texture = texture
	match direction:
		"NW":
			sp.horizontal_alignment = -1.0
			sp.vertical_alignment = -1.0
		"NE":
			sp.horizontal_alignment = 1.0
			sp.vertical_alignment = -1.0
		"SE":
			sp.horizontal_alignment = 1.0
			sp.vertical_alignment = 1.0
		"SW":
			sp.horizontal_alignment = -1.0
			sp.vertical_alignment = 1.0
		"FullRect":
			sp.horizontal_alignment = 0.0
			sp.vertical_alignment = 0.0
			sp.cover = true
		"":
			sp.horizontal_alignment = 0.0
			sp.vertical_alignment = 0.0
		_:
			# :TODO:
			pass
	
	sp.z_index = 99
	self.add_child( sp )
	var id = self._next_overlay_id
	self._next_overlay_id += 1
	
	self._overlays[ id ] = sp
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	return id

func set_coins( value: int ) -> void:
	self.game.get_game_manager().set_coins( value )

func set_distance_in_m( value: int ) -> void:
	self.game.get_game_manager().set_distance_in_m( value )

func hide_toasts() -> void:
	%DialogManager.close_dialog( DialogIds.Id.TOAST_DIALOG, 0.0 )
	
func hide_developer_dialog() -> void:
	%DialogManager.close_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.0 )

func show_toasts() -> void:
	%DialogManager.open_dialog( DialogIds.Id.TOAST_DIALOG, 0.0 )
