extends Dialog
class_name KidsModeEnableDialog

@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _ready():
	if OS.get_name() != "HTML5":
		self.rich_text_label.connect("meta_clicked", _on_meta_clicked)

func _on_meta_clicked(meta):
	OS.shell_open(meta)

func close( duration: float):
	fade_out( duration )

	
func open( duration: float):
	self._dialog_manager.game.pause()
	fade_in( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )

func _on_close_button_pressed() -> void:
	self._dialog_manager.close_dialog(DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3)

func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()
