@tool

extends Dialog

enum AnimationStep {
	NONE,
	START_COINS,
	STOP_COINS,
	DISTANCE_START,
	DISTANCE_STOP,
}

@export var game: Game = null

@export var coinsResultRow: ResultRow = null
@export var distanceResultRow: ResultRow = null
@export var bestDistanceResultRow: ResultRow = null
@export var totalDistanceResultRow: ResultRow = null

@export_tool_button("Prepare Demo Results") var prepare_demo_results_action = _prepare_demo_results
@export_tool_button("Prepare High Demo Results") var prepare_high_demo_results_action = _prepare_high_demo_results

@export var animation_step: AnimationStep = AnimationStep.NONE  : set = _set_animation_step
@export var anim_coin_percentage: float = 0.0
@export var anim_distance_percentage: float = 0.0

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _start_coins: int = 0
var _new_coins: int = 0

var _start_distance: int = 0
var _new_distance: int = 0

var _bestDistance: int = 0
	
var _was_best_distance: bool = false

func _set_animation_step( step: AnimationStep ) -> void:
	var sound_manager := self.game.get_sound_manager()
	if sound_manager == null:
		return
	match step:
		AnimationStep.START_COINS:
			sound_manager.trigger_effect( SoundEffects.Id.PICKED_COIN_LOOP )
			pass
		AnimationStep.STOP_COINS:
			sound_manager.fade_out_effect( SoundEffects.Id.PICKED_COIN_LOOP, 0.3 )
			pass
		AnimationStep.DISTANCE_START:
			sound_manager.trigger_effect( SoundEffects.Id.DISTANCE_COUNT_LOOP )
		AnimationStep.DISTANCE_STOP:
			sound_manager.fade_out_effect( SoundEffects.Id.DISTANCE_COUNT_LOOP, 0.3 )
		_:
			pass
	animation_step = step
	
func _ready() -> void:
	coinsResultRow.clear()
	distanceResultRow.clear()
	bestDistanceResultRow.clear()
	totalDistanceResultRow.clear()

func set_game( g: Game):
	self.game = g

func _process(_delta: float) -> void:
	var total_coins = _start_coins + self.anim_coin_percentage * _new_coins
	coinsResultRow.setTotal( "%d" % total_coins )
	var current_coins = ( 1.0 - self.anim_coin_percentage ) * _new_coins
	if current_coins > 0:
		coinsResultRow.setCurrent( "%d" % current_coins )
	else:
		coinsResultRow.setCurrent("")

	var distance = self.anim_distance_percentage * _new_distance
	distanceResultRow.setTotal( "%d m" % distance )
	var current_distance = ( 1.0 - self.anim_distance_percentage ) * _new_distance
	if current_distance > 0:
		distanceResultRow.setCurrent( "%d m" % current_distance )
	else:
		distanceResultRow.setCurrent("")

	var total_distance = _start_distance + self.anim_distance_percentage * _new_distance
	totalDistanceResultRow.setTotal( "%d m" % total_distance )
	
	var bestDistance = max(distance, _bestDistance)
	bestDistanceResultRow.setTotal("%d m" % bestDistance)
	
	var best = distance >= bestDistance && _was_best_distance
	distanceResultRow.was_best = best
	bestDistanceResultRow.was_best = best
	
	return

func _prepare_results():
	var player = game.get_player()
	var coins = player.lastCoins()
	var distance = player.lastDistance()
	var first_ranks = player.get_first_ranks_on_last_leaderboard_update()
	var start_coins = player.coins();
	var start_distance = player.totalDistance();
	_bestDistance = player.prev_best_distance();
	
	self._prepare_results_from(
		coins,
		distance,
		first_ranks,
		start_coins,
		start_distance,
	)

func _prepare_results_from(
	coins: int,
	distance: int,
	first_ranks:Array[ LeaderboardTypes.Type ],
	start_coins: int,
	start_distance: int,
) -> void:
	self._start_coins = start_coins
	self._new_coins = coins
	
	self._start_distance = start_distance
	self._new_distance = distance

	_was_best_distance = first_ranks.has( LeaderboardTypes.Type.LOCAL_DISTANCE )

	var duration = 4.0*log( max(coins, distance) )/log(10)+1.3
	var anim_duration = 3.0
	var speed = anim_duration / duration
	
	# print("Duration: %f %s" % [ duration, speed ] )
	self.animation_player.play( "CountUp" , -1.0, speed, false )

	return

	
# :TODO: decide if we need this?!
#	coinsResultRow.clear()
#	distanceResultRow.clear()
#	bestDistanceResultRow.clear()
#	totalDistanceResultRow.clear()
	
	
func _prepare_demo_results() -> void:
	var coins = 50
	var distance = 60
	var first_ranks: Array[ LeaderboardTypes.Type ] = [ LeaderboardTypes.Type.LOCAL_DISTANCE ]
	
	var start_coins = 100
	var start_distance = 1000
	_bestDistance = 20;
	
	self._prepare_results_from(
		coins,
		distance,
		first_ranks,
		start_coins,
		start_distance,
	)

func _prepare_high_demo_results() -> void:
	var coins = 500
	var distance = 60000
	var first_ranks: Array[ LeaderboardTypes.Type ] = [ LeaderboardTypes.Type.LOCAL_DISTANCE ]
	
	var start_coins = 10
	var start_distance = 100
	_bestDistance = 10000;
	
	self._prepare_results_from(
		coins,
		distance,
		first_ranks,
		start_coins,
		start_distance,
	)
	
func toggle( duration: float ):
	toggle_fade( duration )

func close( duration: float):
	fade_out( duration )

func open( duration: float):
	_prepare_results()
	fade_in( duration )

func toggle_fade( duration: float ):
	$ResultDialogFadeableContainer.toggle_fade( duration )

func fade_in( duration: float ):
	$ResultDialogFadeableContainer.fade_in( duration )

func fade_out( duration: float ):
	$ResultDialogFadeableContainer.fade_out( duration )


func _on_skill_upgrade_button_pressed() -> void:
	_dialog_manager.open_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )

func _on_result_dialog_fadeable_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_result_dialog_fadeable_container_on_faded_in() -> void:
	opened()

func _on_result_dialog_fadeable_container_on_fading_out( _duration: float  ) -> void:
	closing()

func _on_result_dialog_fadeable_container_on_faded_out() -> void:
	closed()


func _on_leaderboard_button_pressed() -> void:
	_dialog_manager.open_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )


func _on_achievement_button_pressed() -> void:
	_dialog_manager.open_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
