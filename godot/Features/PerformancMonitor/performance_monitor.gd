# class_name PerfomanceMonitor
extends Node2D

var _current_areas: Dictionary[String, int] = {}
var _historical_areas: Dictionary[String, PerformanceAreaStats] = {}
var _path: Array[String] = []

func draw( ci: CanvasItem ) -> void:
	var x = 0
	var w = 20.0
	var y = 500
	var s = 2.0
	for a in self._current_areas:
		var d = self._current_areas[a]
		ci.draw_line( Vector2( x, y ), Vector2(x,y-d*s), Color.WHITE, w )
		x = x + w

func next_frame() -> void:
	for a in self._current_areas:
		self._current_areas[a] = 0
	
func enter_performance_area( name: String ) -> void:
	self._path.push_back( name )
	pass

func leave_performance_area( name: String, duration: int ) -> void:
	var full_name = "/".join( self._path )
	var n = self._path.pop_back()

	# Update current frame (for draw visualization)
	var current = self._current_areas.get_or_add( full_name, 0 )
	self._current_areas[full_name] = current + duration

	# Update historical statistics
	if !self._historical_areas.has(full_name):
		self._historical_areas[full_name] = PerformanceAreaStats.new(full_name)

	var stats = self._historical_areas[full_name]
	stats.add_sample(duration, Time.get_ticks_usec())

func get_area_stats(area_name: String) -> PerformanceAreaStats:
	return self._historical_areas.get(area_name, null)

func get_all_stats() -> Dictionary:
	return self._historical_areas.duplicate()

func get_all_area_names() -> Array[String]:
	var names: Array[String] = []
	names.assign(self._historical_areas.keys())
	return names
