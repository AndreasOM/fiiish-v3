extends Control

@export var game: Game = null
@export var skill_point_price: int = 200

# :HACK: should come from config
var _skill_effect_ids = [
	SkillEffectIds.Id.MAGNET_RANGE_FACTOR,
	SkillEffectIds.Id.MAGNET_BOOST_RANGE_FACTOR,
]

func _ready() -> void:
	#var ui = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer/MagnetRangeUpgradeItem
	#ui.setCurrent( 1 )
	#ui.setUnlockable( 5 )

	#ui = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer/MagnetRangeBoostUpgradeItem
	#ui.setCurrent( 2 )
	#ui.setUnlockable( 3 )
	
	_update_all()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	for id in _skill_effect_ids:
		var sui = _get_skill_upgrade_item_for_skill_effect_id( id )
		if sui == null:
			continue
		var current = p.get_skill_effect_level( id )
		sui.setCurrent( current )
		sui.setUnlockable( current+1 )
		

func _prepare_fade_in():
	var p = game.get_player()
	for id in _skill_effect_ids:
		var sui = _get_skill_upgrade_item_for_skill_effect_id( id )
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


func _on_skill_buy_triggered( id: SkillEffectIds.Id, level: int ) -> void:
	print( "Skill buy: %d -> %d" %[ id, level ] )
	# :TODO: handle cost
	var p = game.get_player()
	
	if !p.use_skill_points( 1, "Buy Skill %d" % id ):
		print("Couldn't afford skill %d")
		return
		
	p.set_skill_effect_level( id, level )
	_update_all()



func _get_skill_upgrade_item_for_skill_effect_id( id: SkillEffectIds.Id ) -> SkillUpgradeItem:
	var p = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer
	for c in p.get_children():
		var sui = c as SkillUpgradeItem
		if sui == null:
			continue
		if sui.skill_effect_id == id:
			return sui
	
	return null


func _on_reset_skill_points_button_pressed() -> void:
	var p = game.get_player()
	p.reset_skill_effecs()
	_update_all()
	# _prepare_fade_in()
