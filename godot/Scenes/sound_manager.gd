extends Node
class_name SoundManager

var _fade: float = 0.0
var _fadeSpeed: float = 0.0

var _sound_players: Dictionary[ SoundEffects.Id, SoundPlayer ] = {
	
}

var _soundPlayerScene = preload("res://Scenes/sound_player.tscn")

var _enabled: bool = true

func enable() -> void:
	_enabled = true
	
func disable( duration: float = 0.3 ) -> void:
	_enabled = false
	self.fade_out_all( duration )
	
func _add_sound_player( soundEffect: SoundEffects.Id, amount: int, minSeperation: float, loop: bool, clip: String ):
	#var player: SoundPlayer = preload("res://Scenes/sound_player.tscn")
	var player: SoundPlayer = _soundPlayerScene.instantiate()
	player.load_clip( clip )
	player.set_amount( amount )
	player.set_min_seperation( minSeperation )
	player.set_loop( loop )
	self.add_child(player)
	_sound_players[soundEffect] = player
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_sound_player( SoundEffects.Id.PICKED_COIN, 50, 0.025, false, "res://Sound/picked_coin.wav" )
	_add_sound_player( SoundEffects.Id.FISH_DEATH, 1, 1.0, false, "res://Sound/fiish_death.wav" )
	_add_sound_player( SoundEffects.Id.BUBBLE_BLAST_LOOP, 1, 1.0, true, "res://Sound/bubble_blast_loop.wav" )
	_add_sound_player( SoundEffects.Id.PICKED_COIN_LOOP, 1, 1.0, true, "res://Sound/picked_coin.wav" )
	_add_sound_player( SoundEffects.Id.DISTANCE_COUNT_LOOP, 1, 1.0, true, "res://Sound/distance_count_loop.wav" )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _fadeSpeed != 0.0:
		_fade += _fadeSpeed*delta
		if _fade >= 1.0:
			_fade = 1.0
			_fadeSpeed = 0.0
		elif _fade <= 0.0:
			_fade = 0.0
			# set_stream_paused( true )
			_fadeSpeed = 0.0
		# volume_db = linear_to_db(_fade)
		
func fade_in( duration: float) -> void:
	# set_stream_paused( false )
	# if ! is_playing():
	#	play()

	if duration <= 0.0:
		_fade = 1.0
		return
	_fadeSpeed = 1.0/duration
	
func fade_out( duration: float) -> void:
	if duration <= 0.0:
		_fade = 0.0
		# set_stream_paused( true )
		return
	_fadeSpeed = -1.0/duration

func trigger_effect( soundEffect: SoundEffects.Id ) -> void:
	if !self._enabled:
		return
	var player: SoundPlayer = _sound_players.get( soundEffect )
	if player != null:
		player.trigger()

func fade_out_effect( soundEffect: SoundEffects.Id, duration: float ) -> void:
	var player = _sound_players.get( soundEffect )
	if player:
		player.fade_out( duration )

func fade_out_all( duration: float ) -> void:
	print("fade_out_all")
	for player in _sound_players.values():
		player.fade_out( duration )
