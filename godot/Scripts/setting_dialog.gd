class_name SettingDialog
extends FiiishDialog

@export var game: Game = null
@export var descriptionFile: String
@export var descriptionDemoFile: String
@export var descriptionClassicFile: String
@export var descriptionClassicDemoFile: String
@export var versionFile: String
@onready var settings_info_rich_text_label: RichTextLabel = %SettingsInfoRichTextLabel
@onready var main_menu_toggle_button: FiiishUI_ToggleButton = %MainMenuToggleButton

func _ready() -> void:
	super._ready()

	var player = game.get_player()
	if player.is_main_menu_enabled():
		main_menu_toggle_button.goto_a()
	else:
		main_menu_toggle_button.goto_b()

	var desc = ""		
	if FeatureTags.has_feature("classic"):
		if FeatureTags.has_feature("demo"):
			desc = FileAccess.get_file_as_string( descriptionClassicDemoFile )
		else:
			desc = FileAccess.get_file_as_string( descriptionClassicFile )
	else:
		if FeatureTags.has_feature("demo"):
			desc = FileAccess.get_file_as_string( descriptionDemoFile )
		else:
			desc = FileAccess.get_file_as_string( descriptionFile )

	var versionString = "Fiiish! %s" % [ VersionInfo.version ]
	if VersionInfo.suffix != "":
		versionString = "%s-%s" % [ versionString, VersionInfo.suffix ]
	# versionString = "%s (Godot)" % [ versionString ]
	if FeatureTags.has_feature("demo"):
		versionString = "%s [DEMO]" % [ versionString ]
	%SettingsTitleRichTextLabel.text = versionString
	
	desc = desc.replace( "[commit]", VersionInfo.commit )
	desc = desc.replace( "[build]", VersionInfo.build )
	desc = desc.replace( "[version]", VersionInfo.version )
	desc = desc.replace( "[suffix]", VersionInfo.suffix )
	self.settings_info_rich_text_label.text = desc

	if OS.get_name() != "HTML5":
		self.settings_info_rich_text_label.connect("meta_clicked", _on_meta_clicked)

func _on_meta_clicked(meta) -> void:
	OS.shell_open(meta)

func opening() -> void:
	self.main_menu_toggle_button.grab_focus.call_deferred()
	super.opening()

func set_game( g: Game) -> void:
	self.game = g

#func _process(_delta: float) -> void:
#	pass

func cancel() -> bool:
	self.fade_out( 0.3 )
	return true

func _on_main_menu_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("MainMenu toggle to A")
			game.enable_main_menu()
			
		ToggleButtonContainer.ToggleState.B:
			print("MainMenu toggle to B")
			game.disable_main_menu()

	Events.broadcast_settings_changed()

func _on_kids_mode_texture_button_pressed() -> void:
	self._dialog_manager.open_dialog( DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3 )
