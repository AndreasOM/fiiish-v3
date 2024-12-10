extends Dialog
class_name FiiishConfirmationDialog

enum Mode {
	CANCEL_CONFIRM,
	CANCEL,
	CONFIRM,
}

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
	
func set_title( title: String):
	%TitleLabel.text = title

func set_description( description: String):
	%DescriptionLabel.text = description

func set_mode( mode: Mode):
	match mode:
		Mode.CANCEL:
			%CancelTextureButton.visible = true
			%ConfirmTextureButton.visible = false
		Mode.CONFIRM:
			%CancelTextureButton.visible = false
			%ConfirmTextureButton.visible = true
		Mode.CANCEL_CONFIRM:
			%CancelTextureButton.visible = true
			%ConfirmTextureButton.visible = true
		
