extends Node
class_name ZoneManager


var _zones: Array[ NewZone ] = []

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
	
