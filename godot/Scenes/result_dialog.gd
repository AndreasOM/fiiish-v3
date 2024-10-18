extends Control

@export var game: Game = null

@export var coinsResultRow: ResultRow = null
@export var distanceResultRow: ResultRow = null
@export var bestDistanceResultRow: ResultRow = null
@export var totalDistanceResultRow: ResultRow = null

var _time: float = 0.0
var _coinsTarget: int = 0
var _distanceTarget: int = 0
var _totalDistanceTarget: int = 0
var _bestDistance: int = 0
	
var _coinsGained: EasedInteger = null
var _distanceGained: EasedInteger = null

func _ready() -> void:
	coinsResultRow.clear()
	distanceResultRow.clear()
	bestDistanceResultRow.clear()
	totalDistanceResultRow.clear()

	get_parent().fade_out( 0.0 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _coinsGained != null:
		_time += delta
		
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

		var totalDistance = _totalDistanceTarget - distanceGained
		totalDistanceResultRow.setTotal("%d m" % totalDistance)
		
	
func on_game_state_changed( state: Game.State ):
	print("Result Dialog - State Changed to %s " % state)
	match state:
		Game.State.DYING:
			var game_manager = game.get_game_manager()
			var player = game.get_player()
			var coins = game_manager.coins()
			var distance = game_manager.distance_in_m()
			
			_time = 0.0
			var start_time = 0.0
			var duration = 4.0*log( max(coins, distance) )/log(10)+1.3
			var end_time = start_time + duration

			var start_coins = player.coins();
			var start_distance = player.totalDistance();
			_bestDistance = player.bestDistance();
			
			_coinsGained = EasedInteger.new(start_time, end_time-0.3*duration, coins, 0,
				EasedInteger.EasingFunction.IN_OUT_CUBIC)
			_coinsTarget = start_coins + coins

			_distanceGained = EasedInteger.new(start_time+0.3*duration, end_time, distance, 0,
				EasedInteger.EasingFunction.IN_OUT_CUBIC);
			_distanceTarget = distance;
			_totalDistanceTarget = start_distance + distance
			
			coinsResultRow.clear()
			distanceResultRow.clear()
			bestDistanceResultRow.clear()
			totalDistanceResultRow.clear()

			get_parent().fade_in( 0.3 )
			
		Game.State.DEAD:
			pass
		_:
			if _coinsGained != null:
				_coinsGained = null
			get_parent().fade_out( 0.3 )
			
