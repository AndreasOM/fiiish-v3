extends Node
class_name ZoneManager


var _zones: Array[ NewZone ] = []
var _next_zones: Array[ int ] = []

#func _process(delta: float) -> void:
#	pass


func load_zones_from_folder( folder: String ):
	var zones = DirAccess.get_files_at(folder)
	for zn in zones:
		if !zn.ends_with( ".nzne" ):
			continue
		print("Zones: %s" % zn)
		var fzn = "%s/%s" % [ folder, zn ]
		var z = load( fzn )
		self._zones.push_back( z )
		
func zone_count() -> int:
	return self._zones.size()
	
func get_zone( i: int ) -> NewZone:
	var l = self._zones.size()
	if i >= l:
		push_warning( "Tried to access zone %d / %d" % [ i, l ])
		i = 0
		if l == 0:
			push_error( "Tried acces zone %d / 0 !" % i )
			assert( self._zones.size() > 0 )

	return self._zones[ i ]
	
func pick_random() -> NewZone:
	assert( self._zones.size() > 0 )
	return self._zones.pick_random()
	
func find_zone_index_by_name( name: String ) -> int:
	for i in range( 0, self._zones.size() ):
		var z = self._zones[ i ]
		if z.name == name:
			return i
			
	return -1
	
func push_next_zone( idx: int ):
	self._next_zones.push_back( idx )	
	
func push_next_zone_by_name( name: String ):
	var idx = self.find_zone_index_by_name( name )
	if idx >= 0:
		self.push_next_zone( idx )
	

func pop_next_zone() -> int:
	var next_zone = self._next_zones.pop_front()
	if next_zone == null:
		return -1
	return next_zone
	
func pick_next_zone( blocked_zones: Array [ String ] ):
	var next_zone = null
	
	var max_tries = 100
	while next_zone == null:
		max_tries -= 1
		if max_tries <= 0:
			push_warning("No next zone found")
			return null
		next_zone = self.pick_random()
		if blocked_zones.find( next_zone.name ) >= 0:
			next_zone = null
			
	return next_zone
