extends Dialog
class_name SkillResetConfirmationDialog

signal confirmed
signal cancelled

func _ready() -> void:
	pass


func close( duration: float):
	fade_out( duration )

func open( duration: float):
	fade_in( duration )
		
func fade_out( duration: float ):
	%FadeableContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeableContainer.fade_in( duration )


func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	close( 0.3 )


func _on_confirm_button_pressed() -> void:
	confirmed.emit()
	close( 0.3 )
	
