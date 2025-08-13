class_name MarketingTrailerScript
extends Node
const OverlayFolder = "res://Textures/Overlays/"
func run( script_manager: ScriptManager ) -> bool:
	print("SteamScreenshotScript - run()")
	# await get_tree().create_timer(5.0).timeout

	DirAccess.make_dir_recursive_absolute("user://screenshots/")

	const ScreenSizes = [
		# Vector2i( 0.5*1920, 0.5*1080 ),
		#Vector2i( 2*1920, 2*1080 ),# /*+ 53),
		#Vector2i( 1920, 1080 ),
		Vector2i( 0.5*1920, 0.5*1080 ),
		#Vector2i( 0.25*1920, 0.25*1080 ),
	]
	
	for ss in ScreenSizes:
		print("MarketingTrailerScript - screen size: ", ss)
		script_manager.set_screenshot_prefix("user://screenshots/fiiish-classic-trailer-%dx%d" % [ ss.x, ss.y ])
		get_window().size = ss
		# DisplayServer.window_set_size( ss )
		
		
		await self.take_screenshots( script_manager )
	
	print("SteamScreenshotScript - done()")
	
	get_tree().quit( 0 )

	return true
	
func show_cut_marker( script_manager: ScriptManager ) -> void:
	await script_manager.set_game_speed( 0.1 )
	await script_manager.enable_overlay( "overlay-99-cut_marker.png", "FullRect" )
	await script_manager.wait_seconds( 1.0 )
	await script_manager.clear_overlays()
	await script_manager.set_game_speed( 1.0 )

func follow_path( script_manager: ScriptManager, path: Array) -> void:
	for i in range(path.size()):
		var point = path[ i ]
		var fy = point[ 0 ]
		var zp = point[ 1 ]
		script_manager.set_fish_target_height_range( -75.0+fy, 75.0+fy )
		await script_manager.wait_for_zone_progress( zp )
#		if i == 0:
#			await show_cut_marker( script_manager )

func prepare_zone( script_manager: ScriptManager ) -> void:
	script_manager.clear_next_zones()
	await script_manager.cleanup_pickups()
	
	script_manager.push_next_zone_by_name("8002_Trailer")

	await script_manager.wait_for_game_state( Game.State.WAITING_FOR_START )
	print("SteamScreenshotScript - WAITING_FOR_START")
	
	await script_manager.set_coins( 0 )
	await script_manager.set_distance_in_m( 0 )

	script_manager.set_fish_target_height_range( -150.0, 0.0 )

	script_manager.swim_down()
	await script_manager.wait_for_game_state( Game.State.SWIMMING )

	await script_manager.set_game_speed( 10.0 )
	await script_manager.set_game_speed( 100.0 )
	
	await script_manager.wait_for_zone_name( "8002_Trailer" )
	
func end_run( script_manager: ScriptManager ) -> void:
	script_manager.kill_all_fishes()
	await script_manager.wait_for_game_state( Game.State.GAME_OVER )

	script_manager.swim_down()
	await script_manager.wait_for_game_state( Game.State.PREPARING_FOR_START )
	
func fetch_coins( script_manager: ScriptManager ) -> void:
	await script_manager.set_player_skill_level( SkillIds.Id.COIN_EXPLOSION, 0 )
	await script_manager.set_player_skill_level( SkillIds.Id.COIN_RAIN, 0 )
	await script_manager.set_player_skill_level( SkillIds.Id.LUCK, 0 )
	await script_manager.set_player_skill_level( SkillIds.Id.MAGNET, 5 )
	await script_manager.set_player_skill_level( SkillIds.Id.MAGNET_BOOST_POWER, 5 )
	await script_manager.set_player_skill_level( SkillIds.Id.MAGNET_BOOST_DURATION, 5 )

	await script_manager.wait_for_zone_progress( 4000.0 )
	await script_manager.set_game_speed( 1.0 )
	await script_manager.wait_for_zone_progress( 5000.0 )
	await script_manager.set_game_speed( 10.0 )
	await script_manager.wait_for_zone_progress( 6200.0 )
	await show_cut_marker( script_manager )

	await script_manager.set_player_skill_level( SkillIds.Id.COIN_EXPLOSION, 5 )
	await script_manager.set_player_skill_level( SkillIds.Id.COIN_RAIN, 5 )
	await script_manager.set_player_skill_level( SkillIds.Id.LUCK, 5 )

func take_screenshots( script_manager: ScriptManager ) -> void:
	var capture_explosions = true
	var capture_path_1 = true
	var capture_path_2 = true
	var capture_path_3 = true
	script_manager.reset_screenshot_counter()
	script_manager.clear_overlays()
	script_manager.hide_toasts()
	script_manager.hide_developer_dialog()
	
	await script_manager.reset_player_skills()

	
	
	if capture_explosions:
		await prepare_zone( script_manager )
		await script_manager.set_game_speed( 0.1 )
		await script_manager.enable_overlay( "overlay-00-title_v2-classic.png", "FullRect" )
		await script_manager.wait_seconds( 3 )
		await script_manager.clear_overlays()
		await show_cut_marker( script_manager )
		
		await script_manager.set_game_speed( 10.0 )
		await script_manager.wait_for_zone_progress( 1500.0 )

		await show_cut_marker( script_manager )
		
		await script_manager.set_player_skill_level( SkillIds.Id.COIN_EXPLOSION, 1 )
		await script_manager.wait_for_zone_progress( 3200.0 )

		await show_cut_marker( script_manager )
		
		await script_manager.set_player_skill_level( SkillIds.Id.COIN_EXPLOSION, 3 )
		await script_manager.wait_for_zone_progress( 4800.0 )

		await show_cut_marker( script_manager )
		
		await script_manager.wait_for_zone_progress( 6350.0 )
		
		await show_cut_marker( script_manager )
		await end_run( script_manager )

	if capture_path_1:
		await prepare_zone( script_manager )
		await fetch_coins( script_manager )
		
		const PATH_1 = [
			[   0.0,  6350],
			[-500.0,  7500],
			[ 200.0,  8150],
			[-500.0,  8500],
			[ 200.0,  8800],
			[   0.0, 11200],
		]
		
		await follow_path( script_manager, PATH_1 )
		await show_cut_marker( script_manager )
		await end_run( script_manager )
		
	if capture_path_2:
		await prepare_zone( script_manager )
		await fetch_coins( script_manager )
		
		const PATH_2 = [
			[   0.0,  6350],
			[-500.0,  7500],
			[ 200.0,  8150],
			[-500.0,  8535],
			[ 200.0,  8750],
			#[   0.0, 11200],
		]
		
		await follow_path( script_manager, PATH_2 )
		await end_run( script_manager )
		await show_cut_marker( script_manager )
		
	if capture_path_3:
		await prepare_zone( script_manager )
		await fetch_coins( script_manager )
		
		const PATH_3 = [
			[   0.0,  6350],
			[-500.0,  7500],
			[ 200.0,  8150],
			[-500.0,  8700],
			[ 200.0,  8720],
			#[   0.0, 11200],
		]
		
		await follow_path( script_manager, PATH_3 )
		await end_run( script_manager )
		await show_cut_marker( script_manager )

	script_manager.show_toasts()
