class_name Leaderboard

var _name: String = ""
var _max_entries: int = 0
var _entries: Array[ LeaderboardEntry ] = []

func _init( name: String, max_entries: int = 0 ):
	self._name = name
	self._max_entries = max_entries
	
func set_name( name: String ):
	self._name = name
	
func name() -> String:
	return self._name

func add_entry( participant: String, score: int ):
	var ne = LeaderboardEntry.new( participant, score )
	var p = self._entries.size()
	for i in range( 0, self._entries.size() ):
		var e = self._entries.get( i )
		if score > e.score():
			p = i
			break
			
	self._entries.insert( p, ne )
	if self._max_entries > 0:
		while self._entries.size() > self._max_entries:
			self._entries.pop_back()

func entries() -> Array[ LeaderboardEntry ]:
	return self._entries
