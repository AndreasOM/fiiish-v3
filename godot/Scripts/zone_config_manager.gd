extends Node
class_name ZoneConfigManager


var _zones: Array[ NewZone ] = []
var _next_zones: Array[ int ] = []

var _zone_filenames_to_zones: Dictionary[ String, int ] = {}

#func _process(delta: float) -> void:
#	pass


func load_zones_from_folder( folder: String, prefix: String = "" ) -> void:
	#var zones = DirAccess.get_files_at(folder)
	var zones = ResourceLoader.list_directory( folder )
	if prefix != "":
		prefix = "%s-" % prefix
	for zn in zones:
		if !zn.ends_with( ".nzne" ):
			continue
		print("Zones: %s" % zn)
		var fzn = "%s/%s" % [ folder, zn ]
		var z = load( fzn )
		var zone_name = "%s%s" % [ prefix, zn ]
		self._zone_filenames_to_zones[ zone_name ] = self._zones.size()
		self._zones.push_back( z )

func reload_zone( folder: String, filename: String, prefix: String = "" ) -> void:
	if prefix != "":
		prefix = "%s-" % prefix
	var fzn = "%s/%s" % [ folder, filename ]
	var z = ResourceLoader.load( fzn, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE_DEEP )
	var zone_name = "%s%s" % [ prefix, filename ]
	var i = self.find_zone_index_by_filename( zone_name )
	if i < 0:
		self._zone_filenames_to_zones[ zone_name ] = self._zones.size()
		self._zones.push_back( z )
	else:
		self._zones[ i ] = z
	
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
	
func find_zone_index_by_name( zone_name: String ) -> int:
	for i in range( 0, self._zones.size() ):
		var z = self._zones[ i ]
		if z.name == zone_name:
			return i
			
	return -1

func find_zone_index_by_filename( filename: String ) -> int:
	return self._zone_filenames_to_zones.get( filename, -1)
		
func get_zone_by_filename( filename: String ):
	var i = self.find_zone_index_by_filename( filename )
	if i < 0:
		return null
	return self.get_zone( i )
		
func get_zone_filenames() -> Array[ String ]:
	return self._zone_filenames_to_zones.keys()
	
func clear_next_zones() -> void:
	self._next_zones.clear()
	
func push_next_zone( idx: int ) -> void:
	self._next_zones.push_back( idx )
	
func push_next_zone_by_name( zone_name: String ) -> void:
	var idx = self.find_zone_index_by_name( zone_name )
	if idx >= 0:
		self.push_next_zone( idx )
	else:
		push_warning("Zone '%s' not found" % zone_name)

func push_next_zone_by_filename( zone_filename: String ) -> void:
	var idx = self.find_zone_index_by_filename( zone_filename )
	if idx >= 0:
		self.push_next_zone( idx )

func pop_next_zone() -> int:
	var next_zone = self._next_zones.pop_front()
	if next_zone == null:
		return -1
	return next_zone
	
func pick_next_zone( blocked_zones: Array [ String ] ) -> NewZone:
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
