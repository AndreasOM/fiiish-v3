extends Control

@export var game: Game = null
@export var musicToggleButton: ToggleButtonContainer = null
@export var soundToggleButton: ToggleButtonContainer = null
@export var descriptionFile: String
@export var descriptionDemoFile: String
@export var versionFile: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SettingDialog - _ready()")
	var player = game.get_player()
	if player.isMusicEnabled():
		musicToggleButton.goto_a()
	else:
		musicToggleButton.goto_b()

	if player.isSoundEnabled():
		soundToggleButton.goto_a()
	else:
		soundToggleButton.goto_b()

	var desc = ""		
	if OS.has_feature("demo"):
		desc = FileAccess.get_file_as_string( descriptionDemoFile )
	else:
		desc = FileAccess.get_file_as_string( descriptionFile )
	var version_info = FileAccess.get_file_as_string( versionFile )
	var vlines = version_info.split("\n")
	
	var commit = "local"
	var build = "local"
	var version = "v0.0.0"
	var suffix = "local"
	for l in vlines:
		print( l )
		var p = l.split("=")
		if p.size() != 2:
			print("Skipping %s" % l)
			continue
		match p[ 0 ]:
			"commit": commit = p[ 1 ]
			"build": build = p[ 1 ]
			"version": version = p[ 1 ]
			"suffix": suffix = p[ 1 ]
			_:
				pass
	var versionString = "Fiiish! %s" % [ version ]
	if suffix != "":
		versionString = "%s-%s" % [ versionString, suffix ]
	versionString = "%s (Godot)" % [ versionString ]
	if OS.has_feature("demo"):
		versionString = "%s [DEMO]" % [ versionString ]
	%SettingsTitleRichTextLabel.text = versionString
	
	desc = desc.replace( "[commit]", commit )
	desc = desc.replace( "[build]", build )
	desc = desc.replace( "[version]", version )
	desc = desc.replace( "[suffix]", suffix )
	%SettingsInfoRichTextLabel.text = desc


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_music_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Music toggle to A")
			game.enableMusic()
			
		ToggleButtonContainer.ToggleState.B:
			print("Music toggle to B")
			game.disableMusic()

func _on_sound_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Sound toggle to A")
			game.enableSound()
			
		ToggleButtonContainer.ToggleState.B:
			print("Sound toggle to B")
			game.disableSound()
