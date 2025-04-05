extends MarginContainer
class_name LeaderBoardElement

func _ready():
	self._clear_existing_entries()

func _clear_existing_entries():
	for c in %Entries.get_children():
		%Entries.remove_child(c)
	
func set_leaderboard( leaderboard: Leaderboard, score_formatter: Callable = Callable() ):
	self._clear_existing_entries()

	var ee = preload("res://Dialogs/Leaderboard/leaderboard_element_entry.tscn")

	var es = leaderboard.entries()
	for i in range(0, es.size()):
		var e = es.get( i )
		var ei = ee.instantiate()
		ei.rank = "%d." % ( i + 1 )
		ei.participant = e.participant()
		if score_formatter.is_null():
			ei.score = "%d" % e.score()
		else:
			ei.score = score_formatter.call( e.score() )
			
		%Entries.add_child(ei)
		
