extends Dialog
class_name FiiishConfirmationDialog

enum Mode {
	CANCEL_CONFIRM,
	CANCEL,
	CONFIRM,
}

signal confirmed
signal cancelled
@onready var description_label: RichTextLabel = %DescriptionLabel

func _ready() -> void:
	pass

	if OS.get_name() != "HTML5":
		self.description_label.connect("meta_clicked", _on_meta_clicked)

func _on_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func close( duration: float) -> void:
	fade_out( duration )

func open( duration: float) -> void:
	fade_in( duration )
		
func fade_out( duration: float ) -> void:
	%FadeableContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
	%FadeableContainer.fade_in( duration )


func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	close( 0.3 )


func _on_confirm_button_pressed() -> void:
	confirmed.emit()
	close( 0.3 )
	
func set_title( title: String) -> void:
	%TitleLabel.text = title

func set_description( description: String) -> void:
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
		
