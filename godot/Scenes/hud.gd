extends Control

@export var game: Game = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%DemoContainer.visible = FeatureTags.has_feature("demo")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.game !=	null:
		var game_manager = self.game.get_game_manager()
		if game_manager != null:
			var coins = game_manager.coins()
			%CoinValueLabel.text = "%d" % coins
			var distance = game_manager.distance_in_m()
			%DistanceValueLabel.text = "%dm" % distance
