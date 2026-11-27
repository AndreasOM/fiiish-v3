class_name ScriptManager
extends Node

@onready var game: Game = %Game
@onready var dialog_manager: DialogManager = %DialogManager

const OverlayFolder = "res://Textures/Overlays"
const THROWAWAY_PLAYER_SUFFIX: String = "_script"

# How the throwaway player starts: as a new player, or as a copy of the game's current player.
enum ThrowawayPlayerStart { FRESH, COPY_OF_CURRENT }

const DEFAULT_WAIT_TIMEOUT_SECONDS: float = 60.0
const MIN_WAIT_TIMEOUT_SECONDS: float = 1.0
const MAX_WAIT_TIMEOUT_SECONDS: float = 600.0

## Emitted when a wait ran into the timeout, right before the game quits with exit code 1.
## Handlers run synchronously, anything behind an `await` in them does not run anymore.
signal wait_timed_out( wait_description: String )

signal _wait_wakeup

var _wait_timeout_seconds: float = DEFAULT_WAIT_TIMEOUT_SECONDS
var _is_throwaway_player_in_use: bool = false

var _screenshot_prefix: String = ""
var _screenshot_counter: int = 0

var _overlays: Dictionary[ int, WindowAlignedSprite2D ] = {}
var _next_overlay_id: int = 1

## Sets the timeout for all following waits, clamped to MIN_WAIT_TIMEOUT_SECONDS..MAX_WAIT_TIMEOUT_SECONDS.
func set_wait_timeout( seconds: float ) -> void:
	var clamped = clampf( seconds, MIN_WAIT_TIMEOUT_SECONDS, MAX_WAIT_TIMEOUT_SECONDS )
	if clamped != seconds:
		push_warning( "ScriptManager: wait timeout %.1f s is out of range, using %.1f s." % [ seconds, clamped ] )
	self._wait_timeout_seconds = clamped

# Returns the point in time (Time.get_ticks_msec) at which a wait starting now times out.
func _get_wait_deadline_msec() -> int:
	return Time.get_ticks_msec() + int( 1000.0 * self._wait_timeout_seconds )

# Removes the throwaway player save, reports `reason`, quits with exit code 1 and never returns.
func _abort( reason: String ) -> void:
	if self._is_throwaway_player_in_use:
		self.remove_throwaway_player_save()
	push_error( "ScriptManager: %s, quitting." % [ reason ] )
	get_tree().quit( 1 )
	while true:
		await get_tree().process_frame

# Does nothing before `deadline_msec`. After it: emits wait_timed_out and aborts the run.
func _check_wait_timeout( deadline_msec: int, wait_description: String ) -> void:
	if Time.get_ticks_msec() < deadline_msec:
		return
	self.wait_timed_out.emit( wait_description )
	await self._abort( "%s timed out after %.1f s" % [ wait_description, self._wait_timeout_seconds ] )

func _emit_wait_wakeup() -> void:
	self._wait_wakeup.emit()

# Waits until `sig` (with `sig_arg_count` arguments) is emitted. Times out at `deadline_msec`.
func _wait_for_signal( sig: Signal, sig_arg_count: int, deadline_msec: int, wait_description: String ) -> void:
	# Dictionary: lambdas capture locals by value, a plain bool would not be shared.
	var shared = { "has_signal_arrived": false }
	var on_signal = func() -> void:
		shared.has_signal_arrived = true
		self._wait_wakeup.emit()
	var on_signal_unbound = on_signal.unbind( sig_arg_count ) if sig_arg_count > 0 else on_signal
	sig.connect( on_signal_unbound, CONNECT_ONE_SHOT )
	while !shared.has_signal_arrived:
		var remaining = maxf( 0.05, ( deadline_msec - Time.get_ticks_msec() ) / 1000.0 )
		var timer = get_tree().create_timer( remaining, true, false, true )
		timer.timeout.connect( self._emit_wait_wakeup )
		await self._wait_wakeup
		if timer.timeout.is_connected( self._emit_wait_wakeup ):
			timer.timeout.disconnect( self._emit_wait_wakeup )
		if !shared.has_signal_arrived:
			await self._check_wait_timeout( deadline_msec, wait_description )

func wait_for_game_state( state: Game.State ) -> void:
	await get_tree().process_frame

	var deadline_msec = self._get_wait_deadline_msec()
	var n2 = Game.state_to_name( state )
	while self.game.get_state() != state:
		var n1 = Game.state_to_name( self.game.get_state() )
		print( "game state %s != %s" % [ n1, n2 ] )
		await self._wait_for_signal( self.game.state_changed, 1, deadline_msec, "wait_for_game_state( %s )" % [ n2 ] )

func wait_for_zone_name( n: String ) -> void:
	var deadline_msec = self._get_wait_deadline_msec()
	while self.game.zone_manager.get_current_zone_name() != n:
		await self._check_wait_timeout( deadline_msec, "wait_for_zone_name( \"%s\" )" % [ n ] )
		await get_tree().process_frame

func wait_for_zone_progress( x: float ) -> void:
	var deadline_msec = self._get_wait_deadline_msec()
	var next_print_msec = 0
	while self.game.zone_manager.current_zone_progress < x:
		if next_print_msec <= Time.get_ticks_msec():
			print( "MarketingScreenshot progress %f < %f" % [ self.game.zone_manager.current_zone_progress, x ] )
			next_print_msec = Time.get_ticks_msec() + 1000
		await self._check_wait_timeout( deadline_msec, "wait_for_zone_progress( %f )" % [ x ] )
		await get_tree().process_frame
		
	print( "MarketingScreenshot progress %f" % self.game.zone_manager.current_zone_progress)
		
func wait_seconds( s: float ) -> void:
	var start = Time.get_ticks_msec()
	var end = start + 1000.0*s

	while true:
		await get_tree().process_frame
		var now = Time.get_ticks_msec()
		if end <= now:
			break
	
func set_game_speed( speed: float ) -> void:
	print("delta speed: %f" % speed)
	Engine.time_scale = speed
	Engine.physics_ticks_per_second = int(60.0 * speed)
	# Engine.max_physics_steps_per_frame

	pass
	
func set_fish_target_height_range( min_h: float, max_h: float ) -> void:
	self.game.fish_manager.set_target_height_range( min_h, max_h )
	
func swim_down() -> void:
	var event = InputEventAction.new()
	event.action = "Swim_Dive"
	event.pressed = true
	Input.parse_input_event(event)

func abort_swim() -> void:
	self.game.abort_swim()
	
func kill_all_fishes() -> void:
	self.game.get_game_manager().kill_all_fishes()
	
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
	await self._wait_for_signal( RenderingServer.frame_post_draw, 0, self._get_wait_deadline_msec(), "take_screenshot( \"%s\" )" % [ filename ] )
	var image = get_viewport().get_texture().get_image()
	match image.save_png( full_filename ):
		OK:
			print( "MarketingScreenshot - screenshot saved to %s" % [ full_filename ] )
		var error:
			await self._abort( "saving screenshot %s failed with error %d" % [ full_filename, error ] )
	self._screenshot_counter += 1

func cleanup_pickups() -> void:
	self.game.get_game_manager().cleanup_pickups()
	
func spawn_coin( pos: Vector2 ) -> Pickup:
	return self.game.get_game_manager().spawn_coin( pos )

func spawn_pickup_rain( pos: Vector2 ) -> Pickup:
	return self.game.get_game_manager().spawn_pickup_rain( pos )
	
func spawn_pickup_explosion( pos: Vector2 ) -> Pickup:
	return self.game.get_game_manager().spawn_pickup_explosion( pos )

## Replaces the game's player with one that saves to its own file (THROWAWAY_PLAYER_SUFFIX).
## Also disables Steam writes (achievements, stats, leaderboard scores) for the rest of the run.
func use_throwaway_player( start: ThrowawayPlayerStart ) -> Player:
	SteamWrapper.writes_enabled = false
	self._is_throwaway_player_in_use = true
	var player = Player.new()
	match start:
		ThrowawayPlayerStart.FRESH:
			pass
		ThrowawayPlayerStart.COPY_OF_CURRENT:
			var path = Player.get_save_path( THROWAWAY_PLAYER_SUFFIX )
			var s = Serializer.new()
			if self.game.get_player().serialize( s ) && s.save_file( path ):
				player = Player.load_from_file( path )
			else:
				push_warning( "Couldn't copy the current player to %s, using a fresh one." % [ path ] )
	player._load_suffix = THROWAWAY_PLAYER_SUFFIX
	self.game._player = player
	Events.broadcast_player_changed( player )
	return player

## Deletes the save file of the throwaway player, if there is one.
func remove_throwaway_player_save() -> void:
	var path = Player.get_save_path( THROWAWAY_PLAYER_SUFFIX )
	if FileAccess.file_exists( path ):
		DirAccess.remove_absolute( path )

func reset_player_skills() -> void:
	self.game.get_player().reset_skills()

func give_player_skill_points( amount: int ) -> void:
	self.game.get_player().give_skill_points( amount, "script" )
	
func set_player_skill_level( id: SkillIds.Id, level: int ) -> void:
	self.game.get_player().set_skill_level( id, level )
	self.game.apply_skills()

func buy_player_skill_level( id: SkillIds.Id, level: int ) -> void:
	var skill_name = SkillIds.get_name_for_id( id )
	var p = self.game.get_player()
	var l = p.get_skill_level( id )
	while l < level:
		l = l + 1
		var skill_price = self.game.get_skill_config_manager().get_skill_price( id, l )
		if skill_price <= 0:
			break
		if !p.use_skill_points( skill_price, "Buy Skill %s for %d" % [ skill_name, skill_price ] ):
			push_warning( "Can not afford skill upgrade %s for %d" % [ skill_name, skill_price ] )
			break
		p.set_skill_level( id, l )
	self.game.apply_skills()

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
	if !FileAccess.file_exists( p ):
		push_warning( "Overlay %s not found, skipping it. Overlays are not part of exported builds." % [ p ] )
		return 0
	var image = Image.load_from_file( p )
	if image == null:
		push_warning( "Couldn't load overlay %s, skipping it." % [ p ] )
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

func wait_until_dialog_open( id: DialogIds.Id ) -> void:
	var deadline_msec = self._get_wait_deadline_msec()
	while !self.dialog_manager.is_dialog_open( id ):
		await self._check_wait_timeout( deadline_msec, "wait_until_dialog_open( %d )" % [ id ] )
		await get_tree().process_frame

func wait_until_dialog_closed( id: DialogIds.Id ) -> void:
	var deadline_msec = self._get_wait_deadline_msec()
	while !self.dialog_manager.is_dialog_closed( id ):
		await self._check_wait_timeout( deadline_msec, "wait_until_dialog_closed( %d )" % [ id ] )
		await get_tree().process_frame

func open_dialog( id: DialogIds.Id ) -> void:
	self.dialog_manager.open_dialog( id, 0.3 )

func close_dialog( id: DialogIds.Id ) -> void:
	self.dialog_manager.close_dialog( id, 0.3 )

func mark_achievement_completed( id: String ) -> void:
	self.game.mark_achievement_completed( id )

func collect_all_achievements() -> void:
	self.game.collect_all_achievements()
	await get_tree().process_frame
	
func select_achievement( id: String ) -> void:
	var d: Dialog = self.dialog_manager.get_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG )
	if d == null:
		return
		
	if d.has_method("select_achievement"):
		d.select_achievement( id )

func disable_autopause_on_focus_lost() -> void:
	var fpm: FiiishPauseManager = self.game.get_fiiish_pause_manager()
	if fpm != null:
		fpm.disable_autopause_on_focus_lost()
	
func enable_autopause_on_focus_lost() -> void:
	var fpm: FiiishPauseManager = self.game.get_fiiish_pause_manager()
	if fpm != null:
		fpm.enable_autopause_on_focus_lost()
