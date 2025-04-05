@tool

extends MarginContainer
class_name LeaderboardEntryElement

@export var rank: String = "" : set = _set_rank
@export var participant: String = "" : set = _set_participant
@export var score: String = "" : set = _set_score


func _set_rank( r: String):
	rank = r
	%RankLabel.text = rank

func _set_participant( p: String):
	participant = p
	%ParticipantLabel.text = p

func _set_score( s: String):
	score = s
	%ScoreLabel.text = s
