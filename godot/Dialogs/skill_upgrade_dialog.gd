extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ui = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer/MagnetRangeUpgradeItem
	ui.setCurrent( 1 )
	ui.setUnlockable( 5 )

	ui = $FadeableCenterContainer/TextureRect/MarginContainer/HBoxContainer/ScrollContainer/RightVBoxContainer/MagnetRangeBoostUpgradeItem
	ui.setCurrent( 2 )
	ui.setUnlockable( 3 )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fade_out( duration: float ):
	$FadeableCenterContainer.fade_out( duration )

func fade_in( duration: float ):
	$FadeableCenterContainer.fade_in( duration )


func _on_close_button_pressed() -> void:
	fade_out( 0.3 )
