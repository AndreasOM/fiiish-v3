extends Control

@export var game: Game = null

@export var coinsResultRow: ResultRow = null
@export var distanceResultRow: ResultRow = null
@export var bestDistanceResultRow: ResultRow = null
@export var totalDistanceResultRow: ResultRow = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coinsResultRow.clear()
	distanceResultRow.clear()
	bestDistanceResultRow.clear()
	totalDistanceResultRow.clear()

	get_parent().fade_out( 0.0 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_game_state_changed( state: Game.State ):
	print("Result Dialog - State Changed to %s " % state)
	match state:
		Game.State.DYING:
			get_parent().fade_in( 0.3 )
			var game_manager = game.get_game_manager()
			var player = game.get_player()
			var coins = game_manager.coins()
			var distance = game_manager.distance_in_m()
			
			coinsResultRow.setCurrent( "%d" % coins )
			distanceResultRow.setCurrent( "%d m" % distance )
			
		Game.State.DEAD:
			pass
		_:
			get_parent().fade_out( 0.3 )
			
