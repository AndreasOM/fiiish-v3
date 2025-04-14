@tool

extends MarginContainer
class_name LeaderboardEntryElement

@export var rank: String = "" : set = _set_rank
@export var participant: String = "" : set = _set_participant
@export var score: String = "" : set = _set_score
@export var was_latest: bool = false : set = _set_was_latest
@export var duration: float = 0.3


func _ready():
	var color = get_theme_color( "font_color", "LeaderboardEntryLabel")
	if color == null:
		push_error( "No font_color for LeaderboardEntryLabel")
		color = Color.MAGENTA
	%RankLabel.add_theme_color_override("font_color", color)
	%ParticipantLabel.add_theme_color_override("font_color", color)
	# :HACK: wrong theme variant
	%ScoreLabel.add_theme_color_override("font_color", color)
	_update_look()

func _set_was_latest( b: bool ):
	was_latest = b
	if get_tree() != null:
		_update_look()

func _update_look():
	%RankLabel.theme_type_variation = "LeaderboardEntryLabel"
	%ParticipantLabel.theme_type_variation = "LeaderboardEntryLabel"
	if was_latest:
		var color = get_theme_color( "font_color", "BestLeaderboardEntryLabel")
		var tree = get_tree()
		if color != null && tree != null:
			var tween = tree.create_tween()
			tween.tween_property(%RankLabel, "theme_override_colors/font_color", color, self.duration).set_trans(Tween.TRANS_BOUNCE)
			var tween2 = tree.create_tween()
			tween2.tween_property(%ParticipantLabel, "theme_override_colors/font_color", color, self.duration).set_trans(Tween.TRANS_BOUNCE)
			# :HACK: wrong theme variant
			var tween3 = tree.create_tween()
			tween3.tween_property(%ScoreLabel, "theme_override_colors/font_color", color, self.duration).set_trans(Tween.TRANS_BOUNCE)
	else:
		var color = get_theme_color( "font_color", "LeaderboardEntryLabel")
		%RankLabel.add_theme_color_override("font_color", color)
		%ParticipantLabel.add_theme_color_override("font_color", color)
		# :HACK: wrong theme variant
		%ScoreLabel.add_theme_color_override("font_color", color)

func _set_rank( r: String):
	rank = r
	%RankLabel.text = rank

func _set_participant( p: String):
	participant = p
	%ParticipantLabel.text = p

func _set_score( s: String):
	score = s
	%ScoreLabel.text = s
