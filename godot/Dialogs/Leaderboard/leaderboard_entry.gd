class_name LeaderboardEntry

var _participant: String
var _score: int

func _init( participant: String, score: int ):
	self._participant = participant
	self._score = score

func participant() -> String:
	return self._participant

func score() -> int:
	return self._score
