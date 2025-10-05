# class_name PerfomanceMonitor
extends Node2D

var _current_areas: Dictionary[String, int] = {}
var _historical_areas: Dictionary[String, PerformanceAreaStats] = {}
var _path: Array[String] = []

var _current_frame_start_usec: int = 0
var _current_frame_number: int = 0
var _current_frame_areas: Array[FrameAreaTiming] = []

const MAX_FRAME_HISTORY = 60
var _frame_history: Array[FrameTiming] = []
var _frame_history_index: int = 0

var _worst_frame: FrameTiming = null

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
	var now = Time.get_ticks_usec()

	# Finalize previous frame
	if _current_frame_number > 0:
		var prev_frame = FrameTiming.new(_current_frame_number, _current_frame_start_usec)
		prev_frame.areas = _current_frame_areas.duplicate()
		prev_frame.finalize(now)

		# Add to history (circular buffer)
		if _frame_history.size() < MAX_FRAME_HISTORY:
			_frame_history.push_back(prev_frame)
		else:
			_frame_history[_frame_history_index] = prev_frame
			_frame_history_index = (_frame_history_index + 1) % MAX_FRAME_HISTORY

		# Track worst frame
		if _worst_frame == null:
			_worst_frame = prev_frame
		elif prev_frame.total_duration_usec > _worst_frame.total_duration_usec:
			_worst_frame = prev_frame

	# Start new frame
	_current_frame_start_usec = now
	_current_frame_number = Engine.get_frames_drawn()
	_current_frame_areas.clear()

	# Reset worst frame if too old
	if _worst_frame != null:
		var age = _current_frame_number - _worst_frame.frame_number
		if age > WORST_FRAME_MAX_AGE:
			_worst_frame = null

	# Reset current areas for draw()
	for a in self._current_areas:
		self._current_areas[a] = 0
	
func enter_performance_area( name: String ) -> void:
	self._path.push_back( name )
	pass

func leave_performance_area( name: String, duration: int ) -> void:
	var end_time = Time.get_ticks_usec()
	var start_time = end_time - duration
	var full_name = "/".join( self._path )
	var n = self._path.pop_back()

	# Record for current frame timeline
	var area_timing = FrameAreaTiming.new(full_name, start_time, end_time)
	_current_frame_areas.push_back(area_timing)

	# Update current frame (for draw visualization)
	var current = self._current_areas.get_or_add( full_name, 0 )
	self._current_areas[full_name] = current + duration

	# Update historical statistics
	if !self._historical_areas.has(full_name):
		self._historical_areas[full_name] = PerformanceAreaStats.new(full_name)

	var stats = self._historical_areas[full_name]
	stats.add_sample(duration, end_time)

func get_area_stats(area_name: String) -> PerformanceAreaStats:
	return self._historical_areas.get(area_name, null)

func get_all_stats() -> Dictionary:
	return self._historical_areas.duplicate()

func get_all_area_names() -> Array[String]:
	var names: Array[String] = []
	names.assign(self._historical_areas.keys())
	return names

func get_frame_history() -> Array[FrameTiming]:
	return _frame_history.duplicate()

func get_worst_frame() -> FrameTiming:
	return _worst_frame

func get_current_frame_number() -> int:
	return _current_frame_number

func reset_worst_frame() -> void:
	_worst_frame = null
	_frame_history.clear()
	_frame_history_index = 0

const WATERFALL_LINE_WIDTH = 60
const WATERFALL_MAX_NAME_LENGTH = 15
const WATERFALL_MAX_AREAS = 20
const WORST_FRAME_MAX_AGE = 300

static func _shorten_area_name(name: String, max_len: int) -> String:
	if name.length() <= max_len:
		return name

	# Split by "/" for hierarchical names
	var parts = name.split("/")
	var shortened_parts: Array[String] = []

	for part in parts:
		# Split by uppercase letters to get words
		var words: Array[String] = []
		var current_word = ""
		for i in range(part.length()):
			var c = part[i]
			if i > 0 && c == c.to_upper() && c != c.to_lower():
				if current_word != "":
					words.push_back(current_word)
				current_word = c
			else:
				current_word += c
		if current_word != "":
			words.push_back(current_word)

		# Abbreviate if multiple words
		if words.size() > 1:
			var abbrev = ""
			for word in words:
				if word.length() >= 2:
					abbrev += word.substr(0, 2) + "."
				else:
					abbrev += word + "."
			shortened_parts.push_back(abbrev.trim_suffix("."))
		else:
			shortened_parts.push_back(part)

	var result = "/".join(shortened_parts)
	if result.length() > max_len:
		return result.substr(0, max_len - 2) + ".."
	return result

func get_worst_frame_waterfall() -> String:
	if _worst_frame == null:
		return "No frames recorded yet"

	var frame = _worst_frame
	var lines: Array[String] = []

	# Debug: Print frame info
	if OS.has_feature("editor"):
		print("Worst frame #%d has %d areas" % [frame.frame_number, frame.areas.size()])
		for area in frame.areas:
			print("  - %s: %dus" % [area.name, area.duration_usec])

	# Header
	var duration_ms = float(frame.total_duration_usec) / 1000.0
	lines.push_back("Worst Frame: #%d (%.1fms) - %d areas" % [
		frame.frame_number,
		duration_ms,
		frame.areas.size()
	])

	# Limit number of areas displayed
	var areas_to_show = frame.areas.duplicate()
	if areas_to_show.size() > WATERFALL_MAX_AREAS:
		areas_to_show.resize(WATERFALL_MAX_AREAS)

	# Generate waterfall lines
	for area in areas_to_show:
		var start_offset_ms = float(area.get_start_offset(frame.start_usec)) / 1000.0
		var end_offset_ms = float(area.get_end_offset(frame.start_usec)) / 1000.0
		var duration_ms_area = float(area.duration_usec) / 1000.0

		# Calculate positions
		var start_pos = int((start_offset_ms / duration_ms) * WATERFALL_LINE_WIDTH)
		var end_pos = int((end_offset_ms / duration_ms) * WATERFALL_LINE_WIDTH)
		var bar_width = max(1, end_pos - start_pos)

		# Debug
		if OS.has_feature("editor"):
			print("  %s: offset %.3f-%.3f ms, pos %d-%d, width %d" % [
				area.name, start_offset_ms, end_offset_ms, start_pos, end_pos, bar_width
			])

		# Name line (aligned with start marker |)
		# Time prefix is "XXX.Xms " = 7 chars, then start_pos spaces, then name
		var name_line = "       " + " ".repeat(start_pos) + area.name
		lines.push_back(name_line)

		# Bar line: "start_time spaces |--------| end_time"
		var bar_line = "%5.1fms " % start_offset_ms
		bar_line += " ".repeat(start_pos)
		bar_line += "|" + "-".repeat(max(0, bar_width - 2)) + "|"
		bar_line += " %.1fms" % end_offset_ms
		lines.push_back(bar_line)

	if frame.areas.size() > WATERFALL_MAX_AREAS:
		lines.push_back("... and %d more areas" % (frame.areas.size() - WATERFALL_MAX_AREAS))

	var result = "\n".join(lines)

	# Debug: Print the waterfall
	if OS.has_feature("editor"):
		print("=== WATERFALL ===")
		print(result)
		print("=================")

	return result
