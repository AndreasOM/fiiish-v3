extends Dialog
class_name KidsModeEnableDialog

@export var info_file_v3: String = "res://Resources/kidsmode_info_v3.txt"
@export var info_file_classic: String = "res://Resources/kidsmode_info_classic.txt"

@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	if OS.get_name() != "HTML5":
		self.rich_text_label.connect("meta_clicked", _on_meta_clicked)
		
	var desc = ""
	if OS.has_feature("classic"):
		desc = FileAccess.get_file_as_string( self.info_file_classic )
	else:
		desc = FileAccess.get_file_as_string( self.info_file_v3 )
		
	self.rich_text_label.text = desc

func _on_meta_clicked(meta) -> void:
	OS.shell_open(meta)

func close( duration: float) -> void:
	fade_out( duration )

	
func open( duration: float) -> void:
	self._dialog_manager.game.pause()
	fade_in( duration )

func fade_out( duration: float ) -> void:
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
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


func _on_fresh_game_texture_button_pressed() -> void:
	self._dialog_manager.game.enter_kidsmode_with_fresh_game()
	self._dialog_manager.close_dialog(DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3)	



func _on_with_upgrades_texture_button_pressed() -> void:
	self._dialog_manager.game.enter_kidsmode_with_upgrades()
	self._dialog_manager.close_dialog(DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3)
