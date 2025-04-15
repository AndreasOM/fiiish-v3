class_name LeaderboardEntry

const current_version: int = 1
const oldest_supported_version: int = 1

var _participant: String
var _score: int

func _init( p: String, s: int ):
	self._participant = p
	self._score = s

func serialize( s: Serializer ):
	var version: int = current_version;
	version = s.serialize_u16( version )
	if version < oldest_supported_version:
		push_warning("Version not supported ", version)
		return false
		
	_participant = s.serialize_fixed_string( 64, _participant )
	_score = s.serialize_u32( _score )
	
func participant() -> String:
	return self._participant

func score() -> int:
	return self._score
