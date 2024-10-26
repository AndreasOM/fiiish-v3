extends Node
class_name Game

const SoundEffect = preload("res://Scripts/sound_effect.gd").SoundEffect

enum State {
	INITIAL,
	WAITING_FOR_START,
	SWIMMING,
	DYING,
	DEAD,
	RESPAWNING,
}

signal zone_changed
signal state_changed( state: Game.State )

@export var musicManager: MusicManager = null
@export var soundManager: SoundManager = null

var _player: Player = Player.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game - _ready()")
	
	var player = Player.load()
	if player != null:
		_player = player
		musicManager.fadeOut( 0.0 )
		if _player.isMusicEnabled():
			musicManager.fadeIn( 0.3 )
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_player() -> Player:
	return _player

func _on_debug_ui_zoom_changed( value: float ) -> void:
	%GameNode2D.scale.x = value
	%GameNode2D.scale.y = value

func _on_game_manager_zone_changed( name: String ) -> void:
	self.zone_changed.emit( name )


func _on_debug_ui_goto_next_zone() -> void:
	%GameManager.goto_next_zone()


func get_game_manager() -> GameManager:
	return %GameManager


func _on_fish_state_changed(state: Game.State) -> void:
	state_changed.emit( state )
	match state:
		State.DYING:
			if _player.isSoundEnabled():
				soundManager.trigger_effect( SoundEffect.FISH_DEATH )
				soundManager.trigger_effect( SoundEffect.BUBBLE_BLAST_LOOP )
			_credit_last_swim()
		State.RESPAWNING:
			soundManager.fade_out_effect( SoundEffect.FISH_DEATH, 0.3 )
			soundManager.fade_out_effect( SoundEffect.BUBBLE_BLAST_LOOP, 0.3 )
		_:
			pass

func _credit_last_swim():
	var coins = %GameManager.take_coins()
	_player.give_coins(coins)
	
	var distance = %GameManager.take_current_distance_in_meters()
	_player.apply_distance(distance)
	
	_player.save();

func enableMusic():
	musicManager.fadeIn( 0.3 )
	_player.enableMusic()
	_player.save()
	
func disableMusic():
	musicManager.fadeOut( 0.3 )
	_player.disableMusic()
	_player.save()

func enableSound():
	_player.enableSound()
	_player.save()
	
func disableSound():
	soundManager.fade_out_all( 0.3 )
	_player.disableSound()
	_player.save()


func _on_game_manager_sound_triggered( soundEffect: SoundEffect ) -> void:
	if _player.isSoundEnabled():
		soundManager.trigger_effect( soundEffect )
