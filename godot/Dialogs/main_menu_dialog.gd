extends FiiishDialog
class_name MainMenuDialog

@export var fade_duration: float = 1.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var game_mode: MainMenuEntry = %GameMode
@onready var zone_editor: MainMenuEntry = %ZoneEditor
@onready var about_demo: MainMenuEntry = %AboutDemo
@onready var developer: MainMenuEntry = %Developer
@onready var quit: MainMenuEntry = %Quit


var game: Game = null

func _ready() -> void:
	super._ready()
	
func set_game( g: Game ):
	self.game = g
	
func _update_entries() -> void:
	if OS.has_feature("classic"):
		self.game_mode.state = MainMenuEntry.State.HIDDEN
		self.zone_editor.state = MainMenuEntry.State.HIDDEN
		
	if FeatureTags.has_feature("demo"):
		self.about_demo.state = MainMenuEntry.State.ENABLED
	else:
		self.about_demo.state = MainMenuEntry.State.HIDDEN
		
	if OS.has_feature("pc"):
		self.quit.state = MainMenuEntry.State.ENABLED
	else:
		self.quit.state = MainMenuEntry.State.HIDDEN
	
	var developer_enabled = false
	if FeatureTags.has_feature("editor_runtime"):
		developer_enabled = true
	
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		if steam.isSteamRunning():
			var steam_id = steam.getSteamID()
			var developer_ids = [
				76561199172150142, # andreas OM
			]
			if developer_ids.find( steam_id ) >= 0:
				developer_enabled = true
		
	if developer_enabled:
		self.developer.state = MainMenuEntry.State.ENABLED
		
func cancel() -> bool:
	self.close( 0.3 )
	return true

func _on_zone_editor_pressed() -> void:
	self.close( 0.3 )
	game.goto_zone_editor()

func _on_credits_pressed() -> void:
	self.close( 0.3 )
	_dialog_manager.open_dialog( DialogIds.Id.CREDITS_DIALOG, 0.3 )

func _on_quit_pressed() -> void:
	get_tree().quit(0)

func _on_leader_board_pressed() -> void:
	self.close( 0.3 )
	self._dialog_manager.open_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )

func _on_game_mode_pressed() -> void:
	var mode = self.game.next_game_mode()
	var mode_name = GameModes.get_name_for_mode( mode )
	%GameMode.label = "GameMode: %s" % mode_name

func opening() -> void:
	super.opening()
	self._update_entries()
	
	if (
		# duration > 0.0 && 
		self.animation_player != null
	):
		self.animation_player.play( &"FadeIn", -1.0, 1.0/fade_duration, false )

func closing() -> void:
	super.closing()
	if (
		# duration > 0.0 && 
		self.animation_player != null
	):
		self.animation_player.play( &"FadeIn", -1.0, -1.0/fade_duration, true )

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var frames = Engine.get_frames_drawn()
	print( "Animation Finished: %s (%d)" % [ anim_name, frames ] )

func _on_achievements_pressed() -> void:
	self.close( 0.3 )
	self._dialog_manager.open_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )

func _on_about_demo_pressed() -> void:
	var d = _dialog_manager.open_dialog( DialogIds.Id.ABOUT_DEMO_DIALOG, 0.3 )
	var cd = d as FiiishConfirmationDialog
	cd.set_title("About the Demo")
	cd.set_description("This is the demo version of\nFiiish! Classic\nFor more info check:\n[url]https://games.omnimad.net/games/fiiish-classic[/url]")
	cd.set_mode( FiiishConfirmationDialog.Mode.CONFIRM )
	self.close( 0.3 )

func _on_developer_pressed() -> void:
	get_tree().change_scene_to_file("res://Features/Developer/developer.tscn")

func opened() -> void:
	super.opened()
	%LeaderBoard.grab_focus.call_deferred()
