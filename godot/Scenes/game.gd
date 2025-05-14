extends Node
class_name Game

#@onready var fish: Fish = %Fish
@onready var game_scaler: GameScaler = %GameScaler
@onready var zone_editor_manager: ZoneEditorManager = %ZoneEditorManager

enum State {
	INITIAL,
	WAITING_FOR_START,
	SWIMMING,
	KILLED,
	DYING,
	DYING_WITHOUT_RESULT,
	DEAD,
	RESPAWNING,
}

static func state_to_name( state: Game.State) -> String:
	match state:
		Game.State.INITIAL:
			return "INITIAL"
		Game.State.WAITING_FOR_START:
			return "WAITING_FOR_START"
		Game.State.SWIMMING:
			return "SWIMMING"
		Game.State.KILLED:
			return "KILLED"
		Game.State.DYING:
			return "DYING"
		Game.State.DYING_WITHOUT_RESULT:
			return "DYING_WITHOUT_RESULT"
		Game.State.DEAD:
			return "DEAD"
		Game.State.RESPAWNING:
			return "RESPAWNING"
		_:
			return "[UNKNOWN]"

signal state_changed( state: Game.State )

@export var musicManager: MusicManager = null
@export var soundManager: SoundManager = null

var _player: Player = Player.new()

var _skill_config_manager: SkillConfigManager = SkillConfigManager.new()

var _state: Game.State = Game.State.INITIAL


var _mode: GameModes.Mode = GameModes.Mode.CLASSIC

var _is_in_zone_editor: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game - _ready()")
	
	var player = Player.load()
	if player != null:
		_player = player
		musicManager.fadeOut( 0.0 )
		if _player.isMusicEnabled():
			musicManager.fadeIn( 0.3 )
		if _player.isSoundEnabled():
			soundManager.enable()
		else:
			soundManager.disable( 0.0 )
			
	Events.cheats_changed.connect( _on_cheats_changed )
	self._on_cheats_changed()
	
func _on_cheats_changed():
	var invicible = self._player.isCheatEnabled(	CheatIds.Id.INVINCIBLE )
	%GameManager.set_invincible( invicible )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func is_in_zone_editor() -> bool:
	return self._is_in_zone_editor
	
func goto_zone_editor() -> void:
	%DialogManager.open_dialog( DialogIds.Id.MINI_MAP_DIALOG, 1.0 )
	
	if self._is_in_zone_editor:
		push_warning( "Tried to open zone editor from zone editor")
		return
	self._is_in_zone_editor = true
	Events.broadcast_zone_edit_enabled()

func close_zone_editor() -> void:
	%DialogManager.close_dialog( DialogIds.Id.MINI_MAP_DIALOG, 1.0 )
	
	if !self._is_in_zone_editor:
		push_warning( "Tried to close zone editor without zone editor")
		return
	self._is_in_zone_editor = false
	Events.broadcast_zone_edit_disabled()
	
func get_sound_manager() -> SoundManager:
	return self.soundManager
	
func get_player() -> Player:
	return _player
	
func get_skill_config_manager() -> SkillConfigManager:
	return _skill_config_manager

func get_world_2d() -> World2D:
	return self.game_scaler.get_world_2d()

func _on_debug_ui_zoom_changed( value: float ) -> void:
	%GameNode2D.scale.x = value
	%GameNode2D.scale.y = value

func _on_debug_ui_goto_next_zone() -> void:
	%GameManager.goto_next_zone()


func get_game_manager() -> GameManager:
	return %GameManager

func get_state() -> Game.State:
	return self._state

func _on_fish_state_changed(state: Game.State) -> void:
	state_changed.emit( state )
	self._state = state
	match state:
		# State.DYING:
		State.KILLED:
			soundManager.trigger_effect( SoundEffects.Id.FISH_DEATH )
			# soundManager.trigger_effect( SoundEffects.Id.BUBBLE_BLAST_LOOP )
			_credit_last_swim()
			%GameManager.kill_pickups()
			%ScreenShakeNode2D.trigger()
		State.RESPAWNING:
			soundManager.fade_out_effect( SoundEffects.Id.FISH_DEATH, 0.3 )
			# soundManager.fade_out_effect( SoundEffects.Id.BUBBLE_BLAST_LOOP, 0.3 )
		State.WAITING_FOR_START:
			var f = %Fish as Fish
			if f != null:
				var ses = SkillEffectSet.new()
				ses.apply_skills( _player, _skill_config_manager )
				# f.apply_skills( _player, _skill_config_manager )
				f.set_skill_effect_set( ses )
		_:
			pass

func _credit_last_swim():
	var coins = %GameManager.take_coins()
	_player.give_coins(coins)
	
	var distance = %GameManager.take_current_distance_in_meters()
	_player.apply_distance(distance)
	
	_player.update_leaderboards( coins, distance )
	_player.save();

func save_player():
	_player.save()
	
func enableMusic():
	musicManager.fadeIn( 0.3 )
	_player.enableMusic()
	_player.save()
	
func disableMusic():
	musicManager.fadeOut( 0.3 )
	_player.disableMusic()
	_player.save()

func enableSound():
	soundManager.enable()
	_player.enableSound()
	_player.save()
	
func disableSound():
	soundManager.disable( 0.3 )
	_player.disableSound()
	_player.save()

func isMainMenuEnabled():
	return _player.isMainMenuEnabled()
	
func enableMainMenu():
	_player.enableMainMenu()
	_player.save()
	
func disableMainMenu():
	_player.disableMainMenu()
	_player.save()


func pause():
	var tree = self.get_tree()
	if !tree.is_paused():
		tree.set_pause( true )
	Events.broadcast_game_paused( true )

func resume():
	var tree = self.get_tree()
	if tree.is_paused():
		tree.set_pause( false )
	Events.broadcast_game_paused( false )
	
func toogle_pause() -> bool:
	var tree = self.get_tree()
	var was_paused = tree.is_paused()
	var is_paused = !was_paused
	tree.set_pause(is_paused)
	Events.broadcast_game_paused( is_paused )
	return is_paused

func _on_game_manager_sound_triggered( soundEffect: SoundEffects.Id ) -> void:
	soundManager.trigger_effect( soundEffect )

func next_game_mode():
	self._mode = GameModes.next( self._mode )
	
	return _mode

func _unhandled_input(event: InputEvent) -> void:
	# What the Elf?!
	%GameSubViewport.push_input( event )

func select_zone( filename: String ) -> void:
	%ZoneEditorManager.select_zone( filename )

func select_save_zone( filename: String ) -> void:
	%ZoneEditorManager.select_save_zone( filename )

func _on_zone_editor_tool_selected( tool_id: ZoneEditorToolIds.Id ) -> void:
	self.zone_editor_manager.on_tool_selected( tool_id )
	
func _on_zone_editor_undo_pressed() -> void:
	self.zone_editor_manager.on_undo_pressed()
	
func _on_zone_editor_redo_pressed() -> void:
	self.zone_editor_manager.on_redo_pressed()
	
func zone_editor_command_history_size() -> int:
	return self.zone_editor_manager.command_history_size()
