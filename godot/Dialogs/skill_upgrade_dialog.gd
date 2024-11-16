extends Control

@export var game: Game = null
@export var skill_point_price: int = 200

var _skill_upgrade_item_scene = preload("res://Dialogs/SkillUpgradeElements/SkillUpgradeItem.tscn")

func _ready() -> void:
	_regenerate_skill_upgrade_items()
	_update_all()

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
	if p.spend_coins( skill_point_price, "Buy Skill Point" ):
		p.give_skill_points( 1, "Buy Skill Point" )
		_update_all()
	else:
		print("Can't afford skill point")


func _on_skill_buy_triggered( id: SkillIds.Id, level: int ) -> void:
	var skill_name = SkillIds.get_name_for_id( id )
	print( "Skill buy: (%d) %s -> %d" %[ id, skill_name, level ] )
	# :TODO: handle cost
	var p = game.get_player()
	
	if !p.use_skill_points( 1, "Buy Skill %d" % id ):
		print("Couldn't afford skill %d")
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
