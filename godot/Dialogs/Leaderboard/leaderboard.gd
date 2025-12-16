class_name Leaderboard

enum Type {
	UNKNOWN,
	DUMMY,
	LOCAL,
	STEAM,
}

const current_version: int = 1
const oldest_supported_version: int = 1

var _name: String = ""
var _max_entries: int = 0
var _entries: SerializableArray = SerializableArray.new(
	func() -> LeaderboardEntry:
		return LeaderboardEntry.new("", 0)
)

# not serialized!
var _last_added_entry_position = -1

var _type: Leaderboard.Type = Type.UNKNOWN

func _init( n: String, max_entries: int = 0 ) -> void:
	self._name = n
	self._max_entries = max_entries

func set_type( t: Type ) -> void:
	_type = t
	
func get_type( ) -> Type:
	return _type

func serialize( s: Serializer ) -> bool:
	var version: int = current_version;
	version = s.serialize_u16( version )
	if version < oldest_supported_version:
		push_warning("Version not supported ", version)
		return false
	
	_name = s.serialize_fixed_string( 32, _name )
	_max_entries = s.serialize_u16( _max_entries )
	
	_entries.serialize( s )
	
	return false
		
func set_name( n: String ) -> void:
	self._name = n
	
func name() -> String:
	return self._name

func type_str() -> String:
	return Leaderboard.Type.keys()[ self._type ]

func type() -> Leaderboard.Type:
	return self._type
	
func replace_entry( participant: String, score: int ) -> int:
	self.remove_entry( participant )
	return self.add_entry( participant, score )

func remove_entry( participant: String ) -> void:
	for i in range( 0, self._entries.size() ):
		var e = self._entries.get_entry( i )
		if e == null:
			continue
		var e2 = e as LeaderboardEntry
		if e2 == null:
			continue
		if e2.participant() == participant:
			self._entries.remove_at( i )
			
func add_entry( participant: String, score: int ) -> int:
	var ne = LeaderboardEntry.new( participant, score )
	var p = self._entries.size()
	for i in range( 0, self._entries.size() ):
		var e = self._entries.get_entry( i )
		if score > e.score():
			p = i
			break
			
	self._entries.insert( p, ne )
	if self._max_entries > 0:
		while self._entries.size() > self._max_entries:
			self._entries.pop_back()
	
	if p >= self._max_entries:
		p = -1
		
	self._last_added_entry_position = p
	return p

func clear_last_added_entry_position() -> void:
	self._last_added_entry_position = -1

func last_added_entry_position() -> int:
	return self._last_added_entry_position
	
func entries() -> SerializableArray:
	return self._entries
