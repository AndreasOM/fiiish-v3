extends Control

@export var game: Game = null
@export var skill_point_price: int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ui = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer/MagnetRangeUpgradeItem
	ui.setCurrent( 1 )
	ui.setUnlockable( 5 )

	ui = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer/MagnetRangeBoostUpgradeItem
	ui.setCurrent( 2 )
	ui.setUnlockable( 3 )
	
	_update_skill_points()
	_update_coins()


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

func fade_out( duration: float ):
	$FadeableCenterContainer.fade_out( duration )
	game.save_player()

func fade_in( duration: float ):
	$FadeableCenterContainer.fade_in( duration )
	_update_skill_points()
	_update_coins()


func _on_close_button_pressed() -> void:
	fade_out( 0.3 )


func _on_buy_skill_point_button_pressed() -> void:
	var p = game.get_player()
	if p.spend_coins( skill_point_price, "Buy Skill Point" ):
		p.give_skill_points( 1, "Buy Skill Point" )
		_update_skill_points()
		_update_coins()
	else:
		print("Can't afford skill point")
