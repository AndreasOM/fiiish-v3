extends Node
class_name ZoneConfigManager


var _zones: Array[ NewZone ] = []
var _next_zones: Array[ int ] = []

var _zone_filenames_to_zones: Dictionary[ String, int ] = {}

## Print every candidate and the picked zone in pick_next_zone(). Very noisy, off by default.
var verbose_picking: bool = false

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
		print("Zones: %s (%s)" % [ zn, prefix ])
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
	
const MIN_CANDIDATES: int = 10		# weighted entries before the difficulty band stops widening
const MIN_DISTINCT_ZONES: int = 3	# fewer distinct zones: shrink the recent window instead
const MAX_WIDEN_ROUNDS: int = 60

# recent: zone names played lately, oldest first. Zones in it are avoided. If that leaves too few
# distinct zones the window shrinks (oldest entries dropped first, down to nothing) instead of failing.
func pick_next_zone( blocked_zones: Array [ String ], difficulty: int, recent: Array[ String ] = [] ) -> NewZone:
	var candidates: Array = []
	for window in range( recent.size(), -1, -1 ):
		var excluded: Array[ String ] = blocked_zones.duplicate()
		excluded.append_array( recent.slice( recent.size() - window ) )
		candidates = self._collect_candidates( excluded, difficulty )
		if self._count_distinct( candidates ) >= MIN_DISTINCT_ZONES:
			break
		# window 0 is the last try, take whatever it found

	if self.verbose_picking:
		print( candidates )
	if candidates.size() == 0:
		push_warning("No next zone found")
		return null
			
	var index = candidates.pick_random()
	var next_zone = self._zones[ index ]
	
	if self.verbose_picking:
		print("! picked next zone: %s %d ~ %d" % [ next_zone.name, next_zone.difficulty, difficulty])
	return next_zone

func _count_distinct( candidates: Array ) -> int:
	var seen: Dictionary = {}
	for c in candidates:
		seen[ c ] = true
	return seen.size()

# Weighted list of zone indices (closer to the target difficulty = more entries). Widens the band
# until MIN_CANDIDATES entries from at least MIN_DISTINCT_ZONES zones exist. Gives up (possibly empty) when widening cannot help.
func _collect_candidates( excluded: Array[ String ], difficulty: int ) -> Array:
	var candidates: Array = []			# index into self._zones[]
	var n = self._zones.size()
	var slope = -0.5
	var amplitude = 2.0

	for _round in range( MAX_WIDEN_ROUNDS ):
		for i in range(n):
			var z = self._zones[i]
			if excluded.find( z.name ) >= 0:
				continue
			if z.is_never_pick():
				continue

			var dd = difficulty - z.difficulty
			if dd < 0:	# do not use zones that are too difficult
				continue
			dd = abs( dd )
			var count = amplitude+slope*dd
			if self.verbose_picking:
				print("! %d -> %d *%f [%f %f]" %[ i, dd, count, slope, amplitude])
			for c in range(count):
				candidates.push_back( i )
		if candidates.size() >= MIN_CANDIDATES && self._count_distinct( candidates ) >= MIN_DISTINCT_ZONES:
			break
		slope *= 0.9 #0.5
		amplitude *= 1.1 #2.0

	return candidates
