@tool

extends MarginContainer
class_name LeaderboardEntryElement

@export var rank: String = "" : set = _set_rank
@export var participant: String = "" : set = _set_participant
@export var score: String = "" : set = _set_score
@export var was_latest: bool = false : set = _set_was_latest
@export var duration: float = 0.3


func _ready():
	_update_look()

func _set_was_latest( b: bool ):
	was_latest = b
	_update_look()

func _update_look():
	%RankLabel.highlighted = was_latest
	%ParticipantLabel.highlighted = was_latest
	%ScoreLabel.highlighted = was_latest

func _set_rank( r: String):
	rank = r
	%RankLabel.text = rank

func _set_participant( p: String):
	participant = p
	%ParticipantLabel.text = p

func _set_score( s: String):
	score = s
	%ScoreLabel.text = s
