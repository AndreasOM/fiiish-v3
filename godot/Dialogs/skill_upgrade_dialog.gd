extends Dialog

@export var game: Game = null
#@export var skill_point_price: int = 200

var _skill_upgrade_item_scene = preload("res://Dialogs/SkillUpgradeElements/SkillUpgradeItem.tscn")

var _last_focused_skill_id: SkillIds.Id = SkillIds.Id.MAGNET

func _ready() -> void:
	_regenerate_skill_upgrade_items()
	_update_all()
	# $FadeableCenterContainer/ShopFrameTextureRect/VBoxContainer/BottomMarginContainer/HBoxContainer/ResetSkillPointsButton/SkillResetLabel.focus_neighbor_left = %BuySkillPointsButton
	
#	for x in range(0, 340):
#		var y = _get_price_for_skill_point( x )
#		print("Skill Point Cost: %d -> %d" % [ x, y ]) 

#	var t = 0
#	for x in range(240, 340):
#		t+= _get_price_for_skill_point( x )

#	print("Skill Point Cost: 240-340 -> %d" % [ t ]) 

func set_game( g: Game) -> void:
	self.game = g
	
func _regenerate_skill_upgrade_items() -> void:
	var p = %SkillUpgradeItemContainer
	for c in p.get_children():
		p.remove_child( c )
		c.queue_free()

	var scm = game.get_skill_config_manager()
	var skill_ids = scm.get_skill_ids()
	
	for id in skill_ids:
		var sc = scm.get_skill( id )
		if sc == null:
			continue
		var sui = _skill_upgrade_item_scene.instantiate()
		var s = sui as SkillUpgradeItem
		s.skill_id = sc.skill_id()
		s.title = sc.name
		s.maximum = sc.get_upgrade_levels()
		s.name = "%s" % [ sc.name ]
		s.connect("skill_buy_triggered", _on_skill_buy_triggered )
		
		p.add_child( sui )

func _update_buy_skill_point_button() -> void:
	var p = game.get_player()
	var owned_skill_points = p.gained_skill_points()
	var cost = _get_price_for_skill_point( owned_skill_points )
	if p.can_afford_coins( cost ):
		%BuySkillPointsButton.disabled = false
	else:
		%BuySkillPointsButton.disabled = true
		
func _update_skill_point_cost() -> void:
	var p = game.get_player()
	var owned_skill_points = p.gained_skill_points()
	var cost = _get_price_for_skill_point( owned_skill_points )
	%SkillPointCoinsCostLabel.text = "%d" % cost
	
func _update_skill_points() -> void:
	var p = game.get_player()
	var sp = p.available_skill_points()
	%SkillPointLabel.text = "%d" % sp

func _update_coins() -> void:
	var p = game.get_player()
	var sp = p.coins()
	%CoinsLabel.text = "%d" % sp

	
func _update_skill_upgrade_items() -> void:
	var player = game.get_player()
	var scm = game.get_skill_config_manager()
	var skill_ids = scm.get_skill_ids()
	for id in skill_ids:
		var sc = scm.get_skill( id )
		var sui = _get_skill_upgrade_item_for_skill_id( id )
		if sui == null:
			continue
		var current = player.get_skill_level( id )
		sui.set_current( current )
		sui.set_unlockable( current+1 )
		if sc != null:
			sui.set_demo_maximum( sc.get_max_demo_level() )
		var unlock_price = scm.get_skill_price( id, current+1 )
		sui.unlock_price = unlock_price
		if id == self._last_focused_skill_id:
			sui.grab_focus.call_deferred()
		
	# update focus relationships
	var p = %SkillUpgradeItemContainer
	var prev: SkillUpgradeItemButton = null
	for c in p.get_children():
		var sui = c as SkillUpgradeItem
		if sui == null:
			continue
			
		sui.active_button.set_prev_control( prev )
		sui.active_button.set_next_control( null )
		if prev != null:
			prev.set_next_control( sui.active_button )
			
		prev = sui.active_button
	
	prev.set_next_control( %ResetSkillPointsButton )
	%ResetSkillPointsButton.focus_neighbor_top = %ResetSkillPointsButton.get_path_to( prev )
	%BuySkillPointsButton.focus_neighbor_top = %BuySkillPointsButton.get_path_to( prev )

func _prepare_fade_in() -> void:
	var scm = game.get_skill_config_manager()
	var skill_ids = scm.get_skill_ids()
	
	for id in skill_ids:
		var sui = _get_skill_upgrade_item_for_skill_id( id )
		if sui == null:
			continue
		sui.prepare_fade_in()
		if id == self._last_focused_skill_id:
			sui.grab_focus.call_deferred()
	
func _update_all() -> void:
	_update_skill_points()
	_update_coins()
	_update_skill_upgrade_items()
	_update_skill_point_cost()
	_update_buy_skill_point_button()

func cancel() -> bool:
	self.close( 0.3 )
	return true

func close( duration: float) -> void:
	fade_out( duration )
	_dialog_manager.close_dialog( DialogIds.Id.SKILL_RESET_CONFIRMATION_DIALOG, 0.3 )

func open( duration: float) -> void:
	fade_in( duration )
		
func fade_out( duration: float ) -> void:
	$FadeableCenterContainer.fade_out( duration )
	game.save_player()

func fade_in( duration: float ) -> void:
	$FadeableCenterContainer.fade_in( duration )
	_update_all()
	_prepare_fade_in()


func _on_close_button_pressed() -> void:
	fade_out( 0.3 )


func _on_buy_skill_point_button_pressed() -> void:
	var p = game.get_player()
	var owned_skill_points = p.gained_skill_points()
	var skill_point_price = _get_price_for_skill_point( owned_skill_points )
	if p.spend_coins( skill_point_price, "Buy Skill Point" ):
		p.give_skill_points( 1, "Buy Skill Point" )
		self._last_focused_skill_id = SkillIds.Id.NONE
		_update_all()
	else:
		print("Can't afford skill point")

func _on_skill_buy_triggered( id: SkillIds.Id, level: int ) -> void:
	var skill_name = SkillIds.get_name_for_id( id )
	
	var scm = game.get_skill_config_manager()
	var sc = scm.get_skill( id )
	if sc == null:
		return
	
	var is_demo = FeatureTags.has_feature("demo")
	if is_demo:
		var max_demo_level = sc.get_max_demo_level()
		if level > max_demo_level:
			var d = _dialog_manager.open_dialog( DialogIds.Id.SKILL_NOT_AFFORDABLE_DIALOG, 0.3 )
			var cd = d as FiiishConfirmationDialog
			cd.set_title("Disabled in Demo")
			cd.set_description("You reached the maximum level\navailable in the demo.\n\nGet the full version to upgrade further.\n[url]https://fiiish-classic.omnimad.net[/url]")
			cd.set_mode( FiiishConfirmationDialog.Mode.CONFIRM )
			return

	var p = game.get_player()
	#var skill_price = _get_skill_price( id, level )
	
	var skill_price = scm.get_skill_price( id, level )
	
	if skill_price < 0:
		return

	print( "Skill buy: (%d) %s -> %d for %d skill points" %[ id, skill_name, level, skill_price ] )
	
	if !p.use_skill_points( skill_price, "Buy Skill %s for %d" % [ skill_name, skill_price ] ):
		print("Couldn't afford skill %s for %d" % [ skill_name, skill_price ] )
		var d = _dialog_manager.open_dialog( DialogIds.Id.SKILL_NOT_AFFORDABLE_DIALOG, 0.3 )
		var cd = d as FiiishConfirmationDialog
		cd.set_title("Too Expensive")
		cd.set_description("That would cost %d skill points,\nyou only have %d skill points." % [ skill_price, p.available_skill_points() ] )
		cd.set_mode( FiiishConfirmationDialog.Mode.CONFIRM )

		return
		
	p.set_skill_level( id, level )
	var total_skill_levels = p.get_total_skill_levels()
	game.achievement_counter_manager.set_counter( AchievementCounterIds.Id.SKILL_UPGRADES, total_skill_levels )
	self._last_focused_skill_id = id
	_update_all()



func _get_skill_upgrade_item_for_skill_id( id: SkillIds.Id ) -> SkillUpgradeItem:
	# var p = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer
	var p = %SkillUpgradeItemContainer
	for c in p.get_children():
		var sui = c as SkillUpgradeItem
		if sui == null:
			continue
		if sui.skill_id == id:
			return sui
	
	return null


func _on_skill_reset_confirmed() -> void:
	var p = game.get_player()
	p.reset_skills()
	_update_all()

func _on_skill_reset_cancelled() -> void:
	pass

func _on_reset_skill_points_button_pressed() -> void:
	var d = _dialog_manager.open_dialog( DialogIds.Id.SKILL_RESET_CONFIRMATION_DIALOG, 0.3 )
	var cd = d as FiiishConfirmationDialog
	cd.set_title("Reset Skills?	")
	cd.set_description("This will reset all your skills.\nAre sure?" )
	cd.set_mode( FiiishConfirmationDialog.Mode.CANCEL_CONFIRM )
	
	if cd:
		cd.cancelled.connect( _on_skill_reset_cancelled )
		cd.confirmed.connect( _on_skill_reset_confirmed )

func _get_price_for_skill_point( owned_skill_points: int ) -> int:
	# return 200
	var r = 20+1.138e-01*pow(owned_skill_points,1.472)
	#var r = 6.641e-04*pow(owned_skill_points,2.379)
	# var r = 1.931e-08*pow(owned_skill_points,4.222)
	return ceil(r)

# 1.931E-08*x^4.222

func _on_fadeable_center_container_on_faded_in() -> void:
	opened()

func _on_fadeable_center_container_on_faded_out() -> void:
	closed()

func _on_fadeable_center_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_center_container_on_fading_out( _duration: float ) -> void:
	closing()
