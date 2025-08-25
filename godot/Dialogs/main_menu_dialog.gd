@tool

extends Dialog
class_name MainMenuDialog

@export_tool_button( "FadeIn" ) var fade_in_action = _fade_in.bind()
@export_tool_button( "FadeOut" ) var fade_out_action = _fade_out
@export var fade_duration: float = 1.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var game_mode: MainMenuEntry = %GameMode
@onready var zone_editor: MainMenuEntry = %ZoneEditor
@onready var about_demo: MainMenuEntry = %AboutDemo
@onready var quit: MainMenuEntry = %Quit


var game: Game = null

func _fade_in() -> void:
	if self.animation_player == null:
		self.animation_player = %AnimationPlayer
	# fade_in( fade_duration )
	open( fade_duration )
	

func _fade_out() -> void:
	
	if self.animation_player == null:
		self.animation_player = %AnimationPlayer
	# fade_out( fade_duration )
	close( fade_duration )
	
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
	
func toggle( _duration: float ) -> void:
	self._update_entries()
	# toggle_fade( duration )
	toggle_fade( fade_duration )

func close( duration: float) -> void:
	fade_out( duration )
#	if duration > 0.0:
#		self.animation_player.play( &"FadeIn", -1.0, -1.0/fade_duration, false )

func open( duration: float) -> void:
	self._update_entries()
		
	fade_in( duration )
#	if duration > 0.0:
#		$AnimationPlayer.play( &"FadeIn", -1.0, 1.0/fade_duration, false )

func toggle_fade( duration: float ) -> void:
	$MainMenuFadeableContainer.toggle_fade( duration )

func fade_in( duration: float ) -> void:
	$MainMenuFadeableContainer.fade_in( duration )

func fade_out( duration: float ):
	$MainMenuFadeableContainer.fade_out( duration )


func _on_zone_editor_pressed() -> void:
	game.goto_zone_editor()
	_dialog_manager.close_dialog( DialogIds.Id.MAIN_MENU_DIALOG, 0.3 )

func _on_credits_pressed() -> void:
	print("Credits pressed")
	_dialog_manager.open_dialog( DialogIds.Id.CREDITS_DIALOG, 0.3 )

func _on_quit_pressed() -> void:
	get_tree().quit(0)

func _on_leader_board_pressed() -> void:
	self._dialog_manager.open_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )

func _on_game_mode_pressed() -> void:
	var mode = self.game.next_game_mode()
	var mode_name = GameModes.get_name_for_mode( mode )
	%GameMode.label = "GameMode: %s" % mode_name

func _on_main_menu_fadeable_container_on_fading_in( duration: float ) -> void:
	%LeaderBoard.grab_focus.call_deferred()
	if duration > 0.0 && self.animation_player != null:
		self.animation_player.play( &"FadeIn", -1.0, 1.0/fade_duration, false )


func _on_main_menu_fadeable_container_on_fading_out( duration: float ) -> void:
	if duration > 0.0 && self.animation_player != null:
		self.animation_player.play( &"FadeIn", -1.0, -1.0/fade_duration, true )

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var frames = Engine.get_frames_drawn()
	print( "Animation Finished: %s (%d)" % [ anim_name, frames ] )


func _on_achievements_pressed() -> void:
	self._dialog_manager.close_dialog(DialogIds.Id.MAIN_MENU_DIALOG, 0.3)
	self._dialog_manager.open_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )


func _on_about_demo_pressed() -> void:
	print("About Demo pressed")
	var d = _dialog_manager.open_dialog( DialogIds.Id.ABOUT_DEMO_DIALOG, 0.3 )
	var cd = d as FiiishConfirmationDialog
	cd.set_title("About the Demo")
	cd.set_description("This is the demo version of\nFiiish! Classic\nFor more info check:\n[url]https://games.omnimad.net/games/fiiish-classic[/url]")
	cd.set_mode( FiiishConfirmationDialog.Mode.CONFIRM )
