extends MarginContainer
class_name LeaderBoardElement

func _ready():
	var e = preload("res://Dialogs/Leaderboard/leaderboard_entry.tscn")
	var es = %Entries
	for c in es.get_children():
		es.remove_child(c)
	
	for i in range( 1, 100 ):
		var ei = e.instantiate()
		ei.rank = "%d." % i
		ei.participant = "Dynamic"
		var s = 12345 - i*11
		ei.score = "%d" % s
		es.add_child(ei)
		
	
