@tool

extends Dialog

@export var game: Game = null

@export var coinsResultRow: ResultRow = null
@export var distanceResultRow: ResultRow = null
@export var bestDistanceResultRow: ResultRow = null
@export var totalDistanceResultRow: ResultRow = null

@export_tool_button("Prepare Demo Results") var prepare_demo_results_action = _prepare_demo_results

var _time: float = 0.0
var _coinsTarget: int = 0
var _distanceTarget: int = 0
var _totalDistanceTarget: int = 0
var _bestDistance: int = 0
	
var _coinsGained: EasedInteger = null
var _distanceGained: EasedInteger = null

var _was_best_distance: bool = false

var _coins_start_time: float = 0.0
var _coins_end_time: float = 0.0
var _distance_start_time: float = 0.0
var _distance_end_time: float = 0.0

func _ready() -> void:
	coinsResultRow.clear()
	distanceResultRow.clear()
	bestDistanceResultRow.clear()
	totalDistanceResultRow.clear()

func set_game( g: Game):
	self.game = g

func _process(delta: float) -> void:
	if _coinsGained != null:
		var was_distance_ended = _time > self._distance_end_time - 1.5
		_time += delta
		var is_distance_ended = _time > self._distance_end_time - 1.5
		var distance_ended = !was_distance_ended && is_distance_ended
		
		var coinsGained = _coinsGained.get_for_time(_time)
		if (coinsGained != 0):
			coinsResultRow.setCurrent("%d" % coinsGained)
		else:
			coinsResultRow.setCurrent("")

		var coins = _coinsTarget - coinsGained
		coinsResultRow.setTotal("%d" % coins)
		
		var distanceGained = _distanceGained.get_for_time(_time)
		if (distanceGained != 0):
			distanceResultRow.setCurrent( "%d m" % distanceGained )
		else:
			distanceResultRow.setCurrent("")

		var distance = _distanceTarget - distanceGained
		distanceResultRow.setTotal("%d m" % distance)

		var bestDistance = max(distance, _bestDistance)
		bestDistanceResultRow.setTotal("%d m" % bestDistance)

		if distance >= bestDistance:
			#print("New best distance %d" % distance)
			distanceResultRow.was_best = _was_best_distance
			bestDistanceResultRow.was_best = _was_best_distance
		#else:
			#print("---")
			
		#if distance_ended:
		#	distanceResultRow.was_best = _was_best_distance
		#	bestDistanceResultRow.was_best = _was_best_distance 
			
		var totalDistance = _totalDistanceTarget - distanceGained
		totalDistanceResultRow.setTotal("%d m" % totalDistance)

func _prepare_results():
	# var game_manager = game.get_game_manager()
	var player = game.get_player()
	# var coins = game_manager.coins()
	# var distance = game_manager.distance_in_m()

	var coins = player.lastCoins()
	var distance = player.lastDistance()

	var first_ranks = player.get_first_ranks_on_last_leaderboard_update()
	var start_coins = player.coins();
	var start_distance = player.totalDistance();
	# _bestDistance = player.bestDistance();
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
	_was_best_distance = first_ranks.has( LeaderboardTypes.Type.LOCAL_DISTANCE )

	_time = 0.0
	var start_time = 0.0
	var duration = 4.0*log( max(coins, distance) )/log(10)+1.3
	var end_time = start_time + duration

	
	self._coins_start_time = start_time
	self._coins_end_time = end_time-0.3*duration
	_coinsGained = EasedInteger.new(
		self._coins_start_time, self._coins_end_time,
		coins, 0,
		EasedInteger.EasingFunction.IN_OUT_CUBIC
	)
	_coinsTarget = start_coins + coins

	self._distance_start_time = start_time+0.3*duration
	self._distance_end_time = end_time
	_distanceGained = EasedInteger.new(
		self._distance_start_time, self._distance_end_time,
		distance, 0,
		EasedInteger.EasingFunction.IN_OUT_CUBIC
	);
	_distanceTarget = distance;
	_totalDistanceTarget = start_distance + distance
	
	coinsResultRow.clear()
	distanceResultRow.clear()
	bestDistanceResultRow.clear()
	totalDistanceResultRow.clear()
	
	distanceResultRow.duration = _distance_end_time-_distance_start_time
	bestDistanceResultRow.duration = _distance_end_time-_distance_start_time
	# distanceResultRow.was_best = _was_best_distance
	# bestDistanceResultRow.was_best = _was_best_distance 
	
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
	
func toggle( duration: float ):
	toggle_fade( duration )

func close( duration: float):
	if _coinsGained != null:
		_coinsGained = null
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
