extends Dialog

@export var game: Game = null
@export var musicToggleButton: ToggleButtonContainer = null
@export var soundToggleButton: ToggleButtonContainer = null
@export var mainMenuToggleButton: ToggleButtonContainer = null
@export var descriptionFile: String
@export var descriptionDemoFile: String
@export var descriptionClassicFile: String
@export var descriptionClassicDemoFile: String
@export var versionFile: String
@onready var settings_info_rich_text_label: RichTextLabel = %SettingsInfoRichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SettingDialog - _ready()")
	var settings = game.get_settings()
	if settings.is_music_enabled():
		musicToggleButton.goto_a()
	else:
		musicToggleButton.goto_b()

	if settings.is_sound_enabled():
		soundToggleButton.goto_a()
	else:
		soundToggleButton.goto_b()

	var player = game.get_player()
	if player.is_main_menu_enabled():
		mainMenuToggleButton.goto_a()
	else:
		mainMenuToggleButton.goto_b()

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

func set_game( g: Game) -> void:
	self.game = g


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_music_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Music toggle to A")
			game.enable_music()
			
		ToggleButtonContainer.ToggleState.B:
			print("Music toggle to B")
			game.disable_music()

func _on_sound_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Sound toggle to A")
			game.enable_sound()
			
		ToggleButtonContainer.ToggleState.B:
			print("Sound toggle to B")
			game.disable_sound()

func cancel() -> bool:
	self.fade_out( 0.3 )
	return true

func toggle( duration: float ) -> void:
	toggle_fade( duration )

func close( duration: float) -> void:
	fade_out( duration )

func open( duration: float) -> void:
	fade_in( duration )


func toggle_fade( duration: float ) -> void:
	$SettingsFadeableContainer.toggle_fade( duration )

func fade_in( duration: float ) -> void:
	$SettingsFadeableContainer.fade_in( duration )

func fade_out( duration: float ) -> void:
	$SettingsFadeableContainer.fade_out( duration )


func _on_settings_fadeable_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_settings_fadeable_container_on_faded_in() -> void:
	opened()

func _on_settings_fadeable_container_on_fading_out( _duration: float ) -> void:
	closing()

func _on_settings_fadeable_container_on_faded_out() -> void:
	closed()


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
