class_name SteamScreenshotScript
extends Node
const OverlayFolder = "res://Textures/Overlays/"
func run( script_manager: ScriptManager ) -> bool:
	print("SteamScreenshotScript - run()")
	# await get_tree().create_timer(5.0).timeout

	DirAccess.make_dir_recursive_absolute("user://screenshots/")

	const ScreenSizes = [
		Vector2i( 1920, 1080 ),
	]
	
	for ss in ScreenSizes:
		print("MarketingScreenshotScript - screen size: ", ss)
		script_manager.set_screenshot_prefix("user://screenshots/fiiish-classic-steam-%dx%d" % [ ss.x, ss.y ])
		get_window().size = ss
		
		
		await self.take_screenshots( script_manager )
	
	print("SteamScreenshotScript - done()")
	
	get_tree().quit( 0 )

	return true
	
func take_screenshots( script_manager: ScriptManager ) -> void:
	script_manager.reset_screenshot_counter()
	script_manager.clear_overlays()
	script_manager.hide_toasts()
	script_manager.hide_developer_dialog()
	
	script_manager.clear_next_zones()
	script_manager.push_next_zone_by_name("8000_MarketingScreenshots")
	script_manager.push_next_zone_by_name("8001_Empty")

	await script_manager.wait_for_game_state( Game.State.WAITING_FOR_START )
	print("SteamScreenshotScript - WAITING_FOR_START")
	
	await script_manager.set_coins( 0 )
	await script_manager.set_distance_in_m( 0 )

	# set fish target height
	script_manager.set_fish_target_height_range( -150.0, 0.0 )
	
	await script_manager.enable_overlay( "overlay-00-title_v2-classic.png", "FullRect" )

	### ---=== Screenshot ===--- ###
	await script_manager.take_screenshot( "title" )

	await script_manager.clear_overlays()

	script_manager.swim_down()

	await script_manager.enable_overlay( "overlay-02-help.png", "SE" )
	
	await script_manager.wait_for_zone_progress( 100.0 )
	await script_manager.set_coins( 0 )
	await script_manager.set_distance_in_m( 2 )

	### ---=== Screenshot ===--- ###
	await script_manager.take_screenshot( "help_fiiish" )
	await script_manager.clear_overlays()
	
	# ~move fish to position~
	await script_manager.wait_for_zone_name( "8000_MarketingScreenshots" )
	print("SteamScreenshotScript - zone: 8000_MarketingScreenshots")
	await script_manager.wait_for_zone_name( "8001_Empty" )
	print("SteamScreenshotScript - zone: 8001_Empty")

	await script_manager.wait_for_zone_progress( 100.0 )
	await script_manager.set_coins( 500 )
	await script_manager.set_distance_in_m( 123 )
	
	### ---=== Screenshot ===--- ###
	await script_manager.take_screenshot( "just_swim" )
	
	await script_manager.wait_for_zone_progress( 1600.0 )
	await script_manager.set_coins( 1503 )
	await script_manager.set_distance_in_m( 264 )
	
	await script_manager.enable_overlay( "overlay-01-explore.png", "SE" )

	### ---=== Screenshot ===--- ###
	await script_manager.take_screenshot( "explore_the_deep_sea" )
	await script_manager.clear_overlays()

	script_manager.abort_swim()
	
	await script_manager.wait_for_game_state( Game.State.PREPARING_FOR_START )
	print("SteamScreenshotScript - PREPARING_FOR_START")
	
	script_manager.show_toasts()
