class_name ScriptManager
extends Node

@onready var game: Game = %Game

const OverlayFolder = "res://Textures/Overlays/"

var _screenshot_prefix: String = ""
var _screenshot_counter: int = 0
var _overlay: TextureRect = null

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

func disable_overlay() -> void:
	if self._overlay != null:
		self._overlay.queue_free()
	
func enable_overlay( imagefile: String, direction: String ) -> void:
	if self._overlay != null:
		self._overlay.queue_free()

	var  p = "%s/%s" % [ OverlayFolder, imagefile ]
	var image = Image.load_from_file( p )
	var sp = TextureRect.new()
	var texture = ImageTexture.create_from_image(image)
	sp.texture = texture
	var fx = 0.0
	var fy = 0.0
	match direction:
		"NW":
			fx = -1.0
			fy = -1.0
			#sp.anchor_top = 0.0
			#sp.anchor_left = 0.0
			sp.set_anchors_preset( Control.LayoutPreset.PRESET_TOP_LEFT )
		"SE":
			fx = 1.0
			fy = 1.0
			#sp.anchor_bottom = 0.0
			#sp.anchor_right = 0.0
			sp.set_anchors_preset( Control.LayoutPreset.PRESET_BOTTOM_RIGHT )
		_:
			# :TODO:
			pass
			
	fx += 1.0
	fy += 1.0
	var iw = image.get_width()
	var ih = image.get_height()
	var a_width = 1920 - iw
	var a_height = 1080 - ih
	
	self.add_child( sp )
	
	# Note: add_child changes the position so fix it after adding it
	sp.position.x = fx * a_width * 0.5
	sp.position.y = fy * a_height *0.5

	self._overlay = sp

func set_coins( value: int ) -> void:
	self.game.get_game_manager().set_coins( value )

func set_distance_in_m( value: int ) -> void:
	self.game.get_game_manager().set_distance_in_m( value )
