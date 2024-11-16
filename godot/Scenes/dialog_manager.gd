extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SkillUpgradeDialog.fade_out( 0.0 )
	pass

func _on_skills_upgrade_button_pressed() -> void:
	$SkillUpgradeDialog.fade_in( 0.3 )
	pass # Replace with function body.


func _on_game_state_changed(state: Game.State) -> void:
	match state:
		Game.State.RESPAWNING:
			$SkillUpgradeDialog.fade_out( 0.3 )
		Game.State.WAITING_FOR_START:
			$SkillUpgradeDialog.fade_out( 0.3 )
		Game.State.SWIMMING:
			$SkillUpgradeDialog.fade_out( 0.3 )
		_:
			pass
