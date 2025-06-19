extends Node
class_name Game

@onready var game_scaler: GameScaler = %GameScaler
@onready var zone_editor_manager: ZoneEditorManager = %ZoneEditorManager
@onready var entity_config_manager: EntityConfigManager = %EntityConfigManager
@onready var fish_manager: FishManager = %FishManager

enum State {
	INITIAL,
	PREPARING_FOR_START,
	WAITING_FOR_START,
	SWIMMING,
	RESULT,
	DEAD,
	DEAD_AUTORESPAWN, # :HACK:
	GAME_OVER,
}

static func state_to_name( state: Game.State) -> String:
	match state:
		Game.State.INITIAL:
			return "INITIAL"
		Game.State.PREPARING_FOR_START:
			return "PREPARING_FOR_START"
		Game.State.WAITING_FOR_START:
			return "WAITING_FOR_START"
		Game.State.SWIMMING:
			return "SWIMMING"
		Game.State.DEAD:
			return "DEAD"
		Game.State.DEAD_AUTORESPAWN:
			return "DEAD_AUTORESPAWN"
		Game.State.RESULT:
			return "RESULT"
		Game.State.GAME_OVER:
			return "GAME_OVER"
		_:
			return "[UNKNOWN]"

signal state_changed( state: Game.State )

@export var musicManager: MusicManager = null
@export var soundManager: SoundManager = null

var _player: Player = Player.new()
var _settings: Settings = Settings.new()

var _skill_config_manager: SkillConfigManager = SkillConfigManager.new()

var _state: Game.State = Game.State.INITIAL


var _mode: GameModes.Mode = GameModes.Mode.CLASSIC

var _is_in_zone_editor: bool = false

var _was_zone_editor_requested: bool = false

const KIDS_MODE_SUFFIX: String = "_kids_mode"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game - _ready()")
	
	self._settings = Settings.load()
	
	var suffix = "" if !self._settings.is_kids_mode_enabled() else KIDS_MODE_SUFFIX
	self._player = Player.load_with_suffix( suffix )
	musicManager.fadeOut( 0.0 )
	if _player.isMusicEnabled():
		musicManager.fadeIn( 0.3 )
	if _player.isSoundEnabled():
		soundManager.enable()
	else:
		soundManager.disable( 0.0 )
	self.get_game_manager().player_changed( self._player )
			
	Events.cheats_changed.connect( _on_cheats_changed )
	self._on_cheats_changed()
	self.fish_manager.last_fish_killed.connect( _on_last_fish_killed )
	self.fish_manager.all_fish_dead.connect( _on_all_fish_dead )
	self.fish_manager.all_fish_waiting_for_start.connect( _on_all_fish_waiting_for_start )
	
func _on_cheats_changed():
	var invicible = self._player.isCheatEnabled(	CheatIds.Id.INVINCIBLE )
	%GameManager.set_invincible( invicible )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match self._state:
		Game.State.INITIAL:
			self._goto_state_waiting_for_start()
		Game.State.RESULT:
			self._goto_state_dead()
		_:
			pass

func is_in_zone_editor() -> bool:
	return self._is_in_zone_editor
	
func goto_zone_editor() -> void:
	match self._state:
		Game.State.SWIMMING:
			self._was_zone_editor_requested = true
			self.fish_manager.kill_all_fishes()
			return
		_:
			self.open_zone_editor()
	
func open_zone_editor() -> void:
	if self._is_in_zone_editor:
		push_warning( "Tried to open zone editor from zone editor")
		return
	self.resume()
	self._is_in_zone_editor = true
	%DialogManager.open_dialog( DialogIds.Id.MINI_MAP_DIALOG, 1.0 )
	Events.broadcast_zone_edit_enabled()

func close_zone_editor() -> void:
	if !self._is_in_zone_editor:
		push_warning( "Tried to close zone editor without zone editor")
		return
	self._is_in_zone_editor = false
	%DialogManager.close_dialog( DialogIds.Id.MINI_MAP_DIALOG, 1.0 )
	%DialogManager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )
	Events.broadcast_zone_edit_disabled()
	self._goto_state_dead()
	self._goto_state_dead_autorespawn()
	self.fish_manager.kill_all_fishes()
	
func get_sound_manager() -> SoundManager:
	return self.soundManager
	
func get_player() -> Player:
	return _player
	
func get_settings() -> Settings:
	return self._settings

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

func _set_state( state: Game.State ) -> void:
	print("Game: _set_state: %s -> %s" % [state_to_name( self._state ), state_to_name( state )])
	if self._state == state:
		return
	self._state = state
	self.state_changed.emit( state )
	Events.broadcast_game_state_changed( state )
	
func _goto_state_initial() -> void:
	self._set_state( Game.State.INITIAL )

func _goto_state_swimming() -> void:
	self._set_state( Game.State.SWIMMING )
	self.fish_manager.start_swimming()
	var pc = self._player.increase_play_count()
	var acm = self.get_game_manager().get_achievement_counter_manager()
	acm.set_counter( AchievementCounterIds.Id.PLAY_COUNT, pc )

func _goto_state_dead() -> void:
	soundManager.trigger_effect( SoundEffects.Id.FISH_DEATH )
	# soundManager.trigger_effect( SoundEffects.Id.BUBBLE_BLAST_LOOP )
	%GameManager.kill_pickups()
	%ScreenShakeNode2D.trigger()
#	if !%GameManager.has_test_zone():
#		_credit_last_swim()
#			else:
#				self.open_zone_editor()
	
	self._set_state( Game.State.DEAD )

func _goto_state_dead_autorespawn() -> void:
	self._set_state( Game.State.DEAD_AUTORESPAWN )
	
func _goto_state_preparing_for_start() -> void:
	soundManager.fade_out_effect( SoundEffects.Id.FISH_DEATH, 0.3 )
	# soundManager.fade_out_effect( SoundEffects.Id.BUBBLE_BLAST_LOOP, 0.3 )
	self._set_state( Game.State.PREPARING_FOR_START )
	%GameManager.cleanup()
	%GameManager.prepare_respawn()
	self.fish_manager.respawn_fishes()

func _goto_state_waiting_for_start() -> void:
	var ses = SkillEffectSet.new()
	ses.apply_skills( _player, _skill_config_manager )
	self.fish_manager.set_skill_effect_set( ses )
	self._set_state( Game.State.WAITING_FOR_START )
	
func _goto_state_result() -> void:
	if !%GameManager.has_test_zone():
		_credit_last_swim()
	self._set_state( Game.State.RESULT )
	
func _goto_state_game_over() -> void:
	self._set_state( Game.State.GAME_OVER )

func _on_last_fish_killed() -> void:
	if self._state != Game.State.SWIMMING:
		return
		
	%GameManager.pause()
		
	if !%GameManager.has_test_zone():
		self._goto_state_result()
	else:
		self._goto_state_dead()

func _on_all_fish_dead() -> void:
	if self._was_zone_editor_requested:
		self._was_zone_editor_requested = false
		# self._goto_state_game_over()
		self._goto_state_preparing_for_start()
		self.open_zone_editor()
		return
	
	if !%GameManager.has_test_zone():
		if self._state != Game.State.DEAD_AUTORESPAWN:
			self._goto_state_game_over()
		else:
			self._goto_state_preparing_for_start()
	else:
		self._goto_state_preparing_for_start()
		
func _on_all_fish_waiting_for_start() -> void:
	self._goto_state_waiting_for_start()
	
func _credit_last_swim():
	var coins = %GameManager.take_coins()
	_player.give_coins(coins)
	
	var distance = %GameManager.take_current_distance_in_meters()
	_player.apply_distance(distance)
	
	self.get_game_manager().sync_achievements_with_player( _player )
	
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
	if !self._is_in_zone_editor:
		match self._state:
			Game.State.WAITING_FOR_START:
				if event.is_action_pressed("swim_down"):
					self._goto_state_swimming()
					return
			Game.State.GAME_OVER:
				if event.is_action_pressed("swim_down"):
					self._goto_state_preparing_for_start()
					return
			_:
				pass

	# What the Elf?!
	%GameSubViewport.push_input( event )

func select_zone( filename: String ) -> void:
	%ZoneEditorManager.select_zone( filename )

func reload_zone( ) -> void:
	%ZoneEditorManager.reload_zone( )

func save_zone( ) -> void:
	%ZoneEditorManager.save_zone( )

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

func _on_zone_editor_spawn_entity_changed( id: EntityId.Id ) -> void:
	self.zone_editor_manager.on_spawn_entity_changed( id )

func is_in_kids_mode() -> bool:
	return self._settings.is_kids_mode_enabled()

func enter_kidsmode_with_upgrades() -> void:
	self._settings.enable_kids_mode()
	self._settings.save()
	self._player.save_with_suffix( KIDS_MODE_SUFFIX )
	Events.broadcast_global_message("KidsMode Enabled")
	Events.broadcast_kids_mode_changed( true )

func enter_kidsmode_with_fresh_game() -> void:
	self._settings.enable_kids_mode()
	self._settings.save()
	self._player = Player.new()
	self._player.save_with_suffix( KIDS_MODE_SUFFIX )
	Events.broadcast_global_message("KidsMode Enabled")
	Events.broadcast_kids_mode_changed( true )

func leave_kids_mode() -> void:
	self._settings.disable_kids_mode()
	self._settings.save()
	self._player = Player.load()
	Events.broadcast_global_message("KidsMode Disabled")
	Events.broadcast_kids_mode_changed( false )
