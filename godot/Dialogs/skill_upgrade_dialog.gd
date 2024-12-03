extends Dialog

@export var game: Game = null
#@export var skill_point_price: int = 200

var _skill_upgrade_item_scene = preload("res://Dialogs/SkillUpgradeElements/SkillUpgradeItem.tscn")

func _ready() -> void:
	_regenerate_skill_upgrade_items()
	_update_all()
	
#	for x in range(0, 340):
#		var y = _get_price_for_skill_point( x )
#		print("Skill Point Cost: %d -> %d" % [ x, y ]) 

#	var t = 0
#	for x in range(240, 340):
#		t+= _get_price_for_skill_point( x )

#	print("Skill Point Cost: 240-340 -> %d" % [ t ]) 

func set_game( game: Game):
	self.game = game
	
func _regenerate_skill_upgrade_items():
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
		s.skill_id = sc.skill_id
		s.title = sc.name
		s.maximum = sc.get_upgrade_levels()
		s.connect("skill_buy_triggered", _on_skill_buy_triggered )
		
		p.add_child( sui )
	
func _update_skill_point_cost():
	var p = game.get_player()
	var owned_skill_points = p.gained_skill_points()
	var cost = _get_price_for_skill_point( owned_skill_points )
	%SkillCostLabel.text = "%d -> 1" % cost
	
func _update_skill_points():
	var p = game.get_player()
	var sp = p.available_skill_points()
	%SkillPointLabel.text = "%d" % sp

func _update_coins():
	var p = game.get_player()
	var sp = p.coins()
	%CoinsLabel.text = "%d" % sp

	
func _update_skill_upgrade_items():
	var p = game.get_player()
	var scm = game.get_skill_config_manager()
	var skill_ids = scm.get_skill_ids()
	for id in skill_ids:
		var sui = _get_skill_upgrade_item_for_skill_id( id )
		if sui == null:
			continue
		var current = p.get_skill_level( id )
		sui.setCurrent( current )
		sui.setUnlockable( current+1 )
		

func _prepare_fade_in():
	var scm = game.get_skill_config_manager()
	var skill_ids = scm.get_skill_ids()
	for id in skill_ids:
		var sui = _get_skill_upgrade_item_for_skill_id( id )
		if sui == null:
			continue
		sui.prepare_fade_in()
	
func _update_all():
	_update_skill_points()
	_update_coins()
	_update_skill_upgrade_items()
	_update_skill_point_cost()

func close( duration: float):
	fade_out( duration )

func open( duration: float):
	fade_in( duration )
		
func fade_out( duration: float ):
	$FadeableCenterContainer.fade_out( duration )
	game.save_player()

func fade_in( duration: float ):
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
		_update_all()
	else:
		print("Can't afford skill point")


func _on_skill_buy_triggered( id: SkillIds.Id, level: int ) -> void:
	var skill_name = SkillIds.get_name_for_id( id )
	var p = game.get_player()
	
	var scm = game.get_skill_config_manager()
	var sc = scm.get_skill( id )
	if sc == null:
		print("Skill config for skill %s not found" % skill_name)
		return
	
	var slc = sc.get_level( level )
	if slc == null:
		print("Skill level config for skill %s [%d] not found" % [ skill_name, level ] )
		return

	var skill_price = slc.cost

	print( "Skill buy: (%d) %s -> %d for %d skill points" %[ id, skill_name, level, skill_price ] )
	
	if !p.use_skill_points( skill_price, "Buy Skill %s for %d" % [ skill_name, skill_price ] ):
		print("Couldn't afford skill %s for %d" % [ skill_name, skill_price ] )
		# :TODO: inform player
		return
		
	p.set_skill_level( id, level )
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


func _on_reset_skill_points_button_pressed() -> void:
	var p = game.get_player()
	p.reset_skills()
	_update_all()
	# _prepare_fade_in()

func _get_price_for_skill_point( owned_skill_points: int ) -> int:
	# return 200
	var r = 20+1.138e-01*pow(owned_skill_points,1.472)
	#var r = 6.641e-04*pow(owned_skill_points,2.379)
	# var r = 1.931e-08*pow(owned_skill_points,4.222)
	return ceil(r)

# 1.931E-08*x^4.222
