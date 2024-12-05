extends Dialog

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

func set_game( game: Game):
	self.game = game

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

func _prepare_results():
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
	print("_on_skill_upgrade_button_pressed")
	_dialog_manager.open_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
