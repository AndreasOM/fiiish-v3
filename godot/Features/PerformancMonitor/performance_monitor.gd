# class_name PerfomanceMonitor
extends Node2D

var _current_areas: Dictionary[String, int] = {}
var _historical_areas: Dictionary[String, PerformanceAreaStats] = {}
var _path: Array[String] = []

func _init() -> void:
	print("[PerformanceMonitor] _init called - autoload is being created")

var _current_frame_start_usec: int = 0
var _current_frame_number: int = 0
var _current_frame_areas: Array[FrameAreaTiming] = []
var _current_frame_total_work_usec: int = 0  # Sum of all durations reported by engine

# Deferred call tracking
var _current_frame_deferred_calls: Array[DeferredCallTiming] = []
var _deferred_call_stats: Dictionary = {}  # "ClassName::method_name" -> DeferredCallStats

# Frame timing breakdown from engine
var _current_frame_game_logic_usec: int = 0
var _current_frame_draw_usec: int = 0
var _current_frame_post_render_usec: int = 0

# Detailed breakdown
var _current_frame_navigation_sync_usec: int = 0
var _current_frame_physics_steps_usec: int = 0
var _current_frame_input_flush_usec: int = 0
var _current_frame_process_usec: int = 0
var _current_frame_message_queue_flush_usec: int = 0
var _current_frame_script_frame_usec: int = 0
var _current_frame_audio_update_usec: int = 0

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
		prev_frame.deferred_calls = _current_frame_deferred_calls.duplicate()
		prev_frame.finalize(now)
		prev_frame.game_logic_usec = _current_frame_game_logic_usec
		prev_frame.draw_usec = _current_frame_draw_usec
		prev_frame.post_render_usec = _current_frame_post_render_usec

		# Store detailed breakdown
		prev_frame.navigation_sync_usec = _current_frame_navigation_sync_usec
		prev_frame.physics_steps_usec = _current_frame_physics_steps_usec
		prev_frame.input_flush_usec = _current_frame_input_flush_usec
		prev_frame.process_usec = _current_frame_process_usec
		prev_frame.message_queue_flush_usec = _current_frame_message_queue_flush_usec
		prev_frame.script_frame_usec = _current_frame_script_frame_usec
		prev_frame.audio_update_usec = _current_frame_audio_update_usec

		# Sanity checks
		if _current_frame_process_usec > 0:
			# Check if game logic breakdown sums correctly
			var game_logic_breakdown = _current_frame_navigation_sync_usec + _current_frame_physics_steps_usec + _current_frame_input_flush_usec + _current_frame_process_usec + _current_frame_message_queue_flush_usec
			var logic_diff = abs(game_logic_breakdown - _current_frame_game_logic_usec)
			if logic_diff > 1000:  # More than 1ms difference
				print("[PerformanceMonitor] Frame #%d: Game logic breakdown (%.1fms) vs total (%.1fms) - %.1fms diff" % [
					_current_frame_number,
					game_logic_breakdown / 1000.0,
					_current_frame_game_logic_usec / 1000.0,
					logic_diff / 1000.0
				])

		# Debug trace disabled - enable if needed for debugging
#		var frame_duration_usec = now - _current_frame_start_usec
#		var gap_usec = frame_duration_usec - _current_frame_total_work_usec
#		var gap_percent = (float(gap_usec) / float(frame_duration_usec)) * 100.0
#		if gap_percent > 80.0:  # If more than 80% untracked
#			print("[PerformanceMonitor] Frame #%d: %.1fms frame time, %.1fms tracked work, %.1fms gap (%.1f%% untracked)" % [
#				_current_frame_number,
#				frame_duration_usec / 1000.0,
#				_current_frame_total_work_usec / 1000.0,
#				gap_usec / 1000.0,
#				gap_percent
#			])

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
	_current_frame_total_work_usec = 0
	_current_frame_game_logic_usec = 0
	_current_frame_draw_usec = 0
	_current_frame_post_render_usec = 0
	_current_frame_navigation_sync_usec = 0
	_current_frame_physics_steps_usec = 0
	_current_frame_input_flush_usec = 0
	_current_frame_process_usec = 0
	_current_frame_message_queue_flush_usec = 0
	_current_frame_script_frame_usec = 0
	_current_frame_audio_update_usec = 0
	_current_frame_deferred_calls.clear()

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

func get_deferred_call_stats() -> Dictionary:
	return _deferred_call_stats.duplicate()

func get_top_deferred_calls(limit: int = 20) -> Array:
	var stats_array: Array = []
	for key in _deferred_call_stats:
		stats_array.push_back(_deferred_call_stats[key])

	# Sort by total time (descending)
	stats_array.sort_custom(func(a, b): return a.total_usec > b.total_usec)

	if stats_array.size() > limit:
		return stats_array.slice(0, limit)
	return stats_array

# Engine hook: called by engine for every node's _process() when auto-tracking is enabled
func _engine_track_node_process_times(node: Node, start_time_usec: int, end_time_usec: int) -> void:
	_track_node_timing(node, start_time_usec, end_time_usec)

# Engine hook: called by engine for every node's _physics_process() when auto-tracking is enabled
func _engine_track_node_physics_process_times(node: Node, start_time_usec: int, end_time_usec: int) -> void:
	_track_node_timing(node, start_time_usec, end_time_usec)

# Engine hook: called for every deferred call during MessageQueue flush
func _engine_track_deferred_call(
	target: Object,
	method: StringName,
	type: int,  # 0=TYPE_CALL, 1=TYPE_NOTIFICATION, 2=TYPE_SET
	start_usec: int,
	end_usec: int
) -> void:
	var duration_usec = end_usec - start_usec

	# Build a unique key for this deferred call type
	var classname = target.get_class() if target != null else "Unknown"
	var type_str = ""
	match type:
		0: type_str = "call"
		1: type_str = "notif"
		2: type_str = "set"
		_: type_str = "unknown"

	var key = "%s::%s [%s]" % [classname, method, type_str]

	# Track this individual call
	var call_timing = DeferredCallTiming.new(target, method, type, start_usec, end_usec)
	_current_frame_deferred_calls.push_back(call_timing)

	# Update aggregate stats
	if !_deferred_call_stats.has(key):
		_deferred_call_stats[key] = DeferredCallStats.new(classname, method, type)

	var stats: DeferredCallStats = _deferred_call_stats[key]
	stats.add_sample(duration_usec, end_usec)

# Engine hook: called at end of frame with timing breakdown
func _engine_track_frame_times(
	frame_start_time: int,
	navigation_sync_begin: int,
	navigation_sync_end: int,
	physics_steps_begin: int,
	physics_steps_end: int,
	input_flush_begin: int,
	input_flush_end: int,
	process_begin: int,
	process_end: int,
	message_queue_flush_begin: int,
	message_queue_flush_end: int,
	game_logic_end_time: int,
	draw_end_time: int,
	script_frame_begin: int,
	script_frame_end: int,
	audio_update_begin: int,
	audio_update_end: int,
	before_frame_delay_time: int,
	process_hook_total_usec: int,
	process_hook_call_count: int,
	physics_process_hook_total_usec: int,
	physics_process_hook_call_count: int,
	process_multiplayer_usec: int,
	process_signal_usec: int,
	process_message_queue1_usec: int,
	process_transform_notif1_usec: int,
	process_nodes_usec: int,
	process_ugc_usec: int,
	process_message_queue2_usec: int,
	process_transform_notif2_usec: int,
	process_scene_change_usec: int,
	process_timers_usec: int,
	process_tweens_usec: int,
	process_transform_notif3_usec: int,
	process_delete_queue_usec: int,
	process_idle_callbacks_usec: int
) -> void:
	_current_frame_game_logic_usec = game_logic_end_time - frame_start_time
	_current_frame_draw_usec = draw_end_time - game_logic_end_time
	_current_frame_post_render_usec = before_frame_delay_time - draw_end_time

	# Store detailed breakdown
	_current_frame_navigation_sync_usec = navigation_sync_end - navigation_sync_begin
	_current_frame_physics_steps_usec = physics_steps_end - physics_steps_begin
	_current_frame_input_flush_usec = input_flush_end - input_flush_begin
	_current_frame_process_usec = process_end - process_begin
	_current_frame_message_queue_flush_usec = message_queue_flush_end - message_queue_flush_begin
	_current_frame_script_frame_usec = script_frame_end - script_frame_begin
	_current_frame_audio_update_usec = audio_update_end - audio_update_begin

	# Verify hook coverage and find leak sources
	var node_overhead_usec = process_nodes_usec - process_hook_total_usec
	var process_breakdown_sum = process_multiplayer_usec + process_signal_usec + process_message_queue1_usec + process_transform_notif1_usec + process_nodes_usec + process_ugc_usec + process_message_queue2_usec + process_transform_notif2_usec + process_scene_change_usec + process_timers_usec + process_tweens_usec + process_transform_notif3_usec + process_delete_queue_usec + process_idle_callbacks_usec

	# Print detailed breakdown only if there's a mismatch
	if node_overhead_usec > 1000 or abs(_current_frame_process_usec - process_breakdown_sum) > 1000:
		print("[PerformanceMonitor] Frame #%d DETAILED BREAKDOWN:" % _current_frame_number)
		print("  Process phase: %.1fms" % (_current_frame_process_usec / 1000.0))
		print("    - Multiplayer: %.1fms" % (process_multiplayer_usec / 1000.0))
		print("    - Signal emission: %.1fms" % (process_signal_usec / 1000.0))
		print("    - Message queue 1: %.1fms" % (process_message_queue1_usec / 1000.0))
		print("    - Transform notif 1: %.1fms" % (process_transform_notif1_usec / 1000.0))
		print("    - Nodes (%.1fms total, %.1fms hooks, %.1fms overhead, %d calls)" % [
			process_nodes_usec / 1000.0,
			process_hook_total_usec / 1000.0,
			node_overhead_usec / 1000.0,
			process_hook_call_count
		])
		print("    - UGC flush: %.1fms" % (process_ugc_usec / 1000.0))
		print("    - Message queue 2: %.1fms" % (process_message_queue2_usec / 1000.0))
		print("    - Transform notif 2: %.1fms" % (process_transform_notif2_usec / 1000.0))
		print("    - Scene change: %.1fms" % (process_scene_change_usec / 1000.0))
		print("    - Timers: %.1fms" % (process_timers_usec / 1000.0))
		print("    - Tweens: %.1fms" % (process_tweens_usec / 1000.0))
		print("    - Transform notif 3: %.1fms" % (process_transform_notif3_usec / 1000.0))
		print("    - Delete queue: %.1fms" % (process_delete_queue_usec / 1000.0))
		print("    - Idle callbacks: %.1fms" % (process_idle_callbacks_usec / 1000.0))
		print("  Breakdown sum: %.1fms (diff from phase: %.1fms)" % [
			process_breakdown_sum / 1000.0,
			(_current_frame_process_usec - process_breakdown_sum) / 1000.0
		])

# Common tracking logic for both _process and _physics_process
func _track_node_timing(node: Node, start_time_usec: int, end_time_usec: int) -> void:
	# Check deny-list: skip if node is deny node or child of deny node
	for deny_node in waterfall_deny_list:
		if node == deny_node or deny_node.is_ancestor_of(node):
			return  # Skip this node and all its children

	var duration_usec = end_time_usec - start_time_usec
	var node_path = str(node.get_path())

	# Track total work reported by engine
	_current_frame_total_work_usec += duration_usec

	# Record for current frame timeline (with node reference)
	var area_timing = FrameAreaTiming.new(node_path, start_time_usec, end_time_usec, node)
	_current_frame_areas.push_back(area_timing)

	# Update current frame (for draw visualization)
	var current = self._current_areas.get_or_add(node_path, 0)
	self._current_areas[node_path] = current + duration_usec

	# Update historical statistics
	if !self._historical_areas.has(node_path):
		self._historical_areas[node_path] = PerformanceAreaStats.new(node_path)

	var stats = self._historical_areas[node_path]
	stats.add_sample(duration_usec, end_time_usec)

const WATERFALL_LINE_WIDTH = 60
const WATERFALL_MAX_NAME_LENGTH = 15
const WATERFALL_MAX_AREAS = 300  # Increased for debugging
const WATERFALL_USEC_THRESHOLD_MS = 1.0  # Show microseconds if below this threshold (ms)
const WORST_FRAME_MAX_AGE = 300

# Waterfall filtering configuration
var waterfall_anchors: Dictionary = {}  # Node -> WaterfallAnchorConfig
var waterfall_deny_list: Array[Node] = []  # Nodes to exclude from tracking
var waterfall_default_max_depth: int = 3  # Default max depth from anchor (0 = unlimited)
var waterfall_default_min_duration_usec: int = 100  # Default min duration

func add_waterfall_anchor(node: Node, prefix: String, max_depth: int = 0, min_duration_usec: int = 0) -> void:
	# Use provided values or fall back to global defaults
	var actual_max_depth = max_depth if max_depth > 0 else waterfall_default_max_depth
	var actual_min_duration = min_duration_usec if min_duration_usec >= 0 else waterfall_default_min_duration_usec
	waterfall_anchors[node] = WaterfallAnchorConfig.new(prefix, actual_max_depth, actual_min_duration)

func add_waterfall_deny_node(node: Node) -> void:
	if not waterfall_deny_list.has(node):
		waterfall_deny_list.push_back(node)

func clear_waterfall_anchors() -> void:
	waterfall_anchors.clear()

func clear_waterfall_deny_list() -> void:
	waterfall_deny_list.clear()

func set_waterfall_default_max_depth(depth: int) -> void:
	waterfall_default_max_depth = depth

func set_waterfall_default_min_duration_usec(min_usec: int) -> void:
	waterfall_default_min_duration_usec = min_usec

class AnchorMatch:
	var config: WaterfallAnchorConfig
	var relative_path: String

	func _init(p_config: WaterfallAnchorConfig, p_relative_path: String) -> void:
		self.config = p_config
		self.relative_path = p_relative_path

func _find_best_anchor(area_node: Node) -> AnchorMatch:
	# Find the closest anchor by checking which gives the shortest relative path

	if area_node == null:
		# Fallback for manual PerformanceArea (no node reference)
		var default_config = WaterfallAnchorConfig.new("", waterfall_default_max_depth, waterfall_default_min_duration_usec)
		return AnchorMatch.new(default_config, "")

	var default_config = WaterfallAnchorConfig.new("", waterfall_default_max_depth, waterfall_default_min_duration_usec)
	var best_match = AnchorMatch.new(default_config, str(area_node.get_path()))
	var shortest_len = best_match.relative_path.length()

	for anchor_node in waterfall_anchors:
		var relative_path = str(anchor_node.get_path_to(area_node))

		if relative_path.length() < shortest_len:
			# Special case: if node IS the anchor (relative_path = "."), use prefix without trailing separator
			var display_path = relative_path
			if relative_path == ".":
				display_path = ""  # Will show just the prefix

			var anchor_config: WaterfallAnchorConfig = waterfall_anchors[anchor_node]
			best_match = AnchorMatch.new(anchor_config, display_path)
			shortest_len = relative_path.length()

	return best_match

static func _get_path_depth(path: String) -> int:
	if path == "" or path == ".":
		return 0
	return path.count("/")

func _calculate_inclusive_duration(node_path: String, all_areas: Array[FrameAreaTiming]) -> int:
	# Calculate total duration of this node and all its descendants
	var total = 0
	for area in all_areas:
		# Include if it's the node itself OR a descendant
		if area.name == node_path or area.name.begins_with(node_path + "/"):
			total += area.duration_usec

	return total

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

	# Debug: Print frame info (commented out - too noisy)
#	if OS.has_feature("editor"):
#		print("Worst frame #%d has %d areas" % [frame.frame_number, frame.areas.size()])
#		for area in frame.areas:
#			print("  - %s: %dus" % [area.name, area.duration_usec])

	# STEP 0.5: Aggregate deferred calls from this frame by ClassName::method [type]
	var aggregated_deferred: Dictionary = {}  # key -> {start, end, total_duration, count}

	if frame.deferred_calls != null and frame.deferred_calls.size() > 0:
		for call in frame.deferred_calls:
			var key = call.get_key()

			if !aggregated_deferred.has(key):
				aggregated_deferred[key] = {
					"start": call.start_usec,
					"end": call.end_usec,
					"total_duration": call.duration_usec,
					"count": 1
				}
			else:
				var agg = aggregated_deferred[key]
				agg.start = min(agg.start, call.start_usec)
				agg.end = max(agg.end, call.end_usec)
				agg.total_duration += call.duration_usec
				agg.count += 1

	# STEP 1: Build complete tree - accumulate ALL nodes into their parents recursively
	# tree_nodes: path -> {duration, count, start, end, original_paths, children, anchor_config}
	var tree_nodes: Dictionary = {}

	for area in frame.areas:
		# Check if node is still valid (may have been freed)
		var valid_node = area.node if area.node != null and is_instance_valid(area.node) else null

		# Find best anchor and get relative path
		var anchor_match: AnchorMatch = _find_best_anchor(valid_node)
		var display_path = anchor_match.config.prefix + anchor_match.relative_path

		# Fallback: if no anchor match and node is invalid/null, use the area name
		if display_path == "" and valid_node == null:
			display_path = area.name

		# Add this node to the tree
		if !tree_nodes.has(display_path):
			tree_nodes[display_path] = {
				"self_duration": 0,
				"inclusive_duration": 0,
				"count": 1,
				"start": area.start_usec,
				"end": area.end_usec,
				"original_path": area.name,
				"anchor_config": anchor_match.config
			}

		tree_nodes[display_path].self_duration += area.duration_usec
		tree_nodes[display_path].inclusive_duration += area.duration_usec

		# Also accumulate into all parent paths
		var parts = display_path.split("/")
		for i in range(parts.size() - 1, 0, -1):
			var parent_parts = parts.slice(0, i)
			var parent_path = "/".join(parent_parts)

			if !tree_nodes.has(parent_path):
				tree_nodes[parent_path] = {
					"self_duration": 0,
					"inclusive_duration": 0,
					"count": 0,
					"start": area.start_usec,
					"end": area.end_usec,
					"original_path": "",
					"anchor_config": anchor_match.config
				}

			tree_nodes[parent_path].inclusive_duration += area.duration_usec
			tree_nodes[parent_path].start = min(tree_nodes[parent_path].start, area.start_usec)
			tree_nodes[parent_path].end = max(tree_nodes[parent_path].end, area.end_usec)

	# STEP 1.5: Add aggregated deferred calls as flat entries (no hierarchy)
	var default_config = WaterfallAnchorConfig.new("[DEFERRED] ", waterfall_default_max_depth, waterfall_default_min_duration_usec)

	for key in aggregated_deferred:
		var agg = aggregated_deferred[key]
		var display_name = "[DEFERRED] %s" % key

		tree_nodes[display_name] = {
			"self_duration": agg.total_duration,
			"inclusive_duration": agg.total_duration,
			"count": agg.count,
			"start": agg.start,
			"end": agg.end,
			"original_path": display_name,
			"anchor_config": default_config
		}

	# STEP 2: Filter what to display based on depth and duration
	var filtered_areas: Array[FrameAreaTiming] = []

	for path in tree_nodes:
		var node = tree_nodes[path]
		var anchor_config: WaterfallAnchorConfig = node.anchor_config

		# Extract relative path (remove anchor prefix)
		var relative_path = path.replace(anchor_config.prefix, "")
		var depth = _get_path_depth(relative_path)

		# Filter by depth
		if anchor_config.max_depth > 0 and depth > anchor_config.max_depth:
			continue  # Skip - too deep

		# Filter by duration (using inclusive duration)
		if anchor_config.min_duration_usec > 0 and node.inclusive_duration < anchor_config.min_duration_usec:
			continue  # Skip - too fast

		# This node passes filters - add it to display
		var new_area = FrameAreaTiming.new(path, node.start, node.end)
		new_area.original_path = node.original_path if node.original_path != "" else path
		# Override duration to use self duration (inclusive is calculated later)
		new_area.duration_usec = node.self_duration
		filtered_areas.push_back(new_area)

	# Sort by start time
	filtered_areas.sort_custom(func(a, b): return a.start_usec < b.start_usec)

	# Limit display
	var areas_to_show = filtered_areas
	if areas_to_show.size() > WATERFALL_MAX_AREAS:
		areas_to_show = areas_to_show.slice(0, WATERFALL_MAX_AREAS)

	# Calculate actual tracked frame duration (last area end - frame start)
	var tracked_duration_usec = frame.total_duration_usec
	if frame.areas.size() > 0:
		# Find the latest end time from all tracked areas
		var latest_end = frame.start_usec
		for area in frame.areas:
			if area.end_usec > latest_end:
				latest_end = area.end_usec
		tracked_duration_usec = latest_end - frame.start_usec

	# Calculate total visible duration (shown in waterfall)
	var visible_duration_usec = 0
	for area in filtered_areas:
		visible_duration_usec += area.duration_usec

	# Calculate total tracked work (sum of all _process() calls)
	var total_work_usec = 0
	for area in frame.areas:
		total_work_usec += area.duration_usec

	# Header with timing breakdown
	var duration_ms = float(tracked_duration_usec) / 1000.0
	var total_work_ms = float(total_work_usec) / 1000.0
	var visible_ms = float(visible_duration_usec) / 1000.0
	var filtered_ms = total_work_ms - visible_ms  # Hidden by filters

	# Use engine-provided breakdown if available
	if frame.game_logic_usec > 0:
		var game_logic_ms = float(frame.game_logic_usec) / 1000.0
		var draw_ms = float(frame.draw_usec) / 1000.0
		var post_render_ms = float(frame.post_render_usec) / 1000.0
		lines.push_back("Worst Frame: #%d (%.1fms total: %.1fms logic, %.1fms draw, %.1fms post | %.1fms shown, %.1fms filtered) - %d areas (from %d)" % [
			frame.frame_number,
			duration_ms,
			game_logic_ms,
			draw_ms,
			post_render_ms,
			visible_ms,
			filtered_ms,
			filtered_areas.size(),
			frame.areas.size()
		])
	else:
		# Fallback to old format if engine timing not available
		var untracked_ms = duration_ms - total_work_ms
		lines.push_back("Worst Frame: #%d (%.1fms total, %.1fms _process, %.1fms shown, %.1fms filtered, %.1fms untracked) - %d areas (from %d)" % [
			frame.frame_number,
			duration_ms,
			total_work_ms,
			visible_ms,
			filtered_ms,
			untracked_ms,
			filtered_areas.size(),
			frame.areas.size()
		])

	# Generate waterfall lines
	for area in areas_to_show:
		var start_offset_ms = float(area.get_start_offset(frame.start_usec)) / 1000.0
		var self_duration_ms = float(area.duration_usec) / 1000.0

		# Get inclusive duration from the tree we built
		var inclusive_duration_usec = area.duration_usec  # Default to self
		if tree_nodes.has(area.name):
			inclusive_duration_usec = tree_nodes[area.name].inclusive_duration

		var inclusive_duration_ms = float(inclusive_duration_usec) / 1000.0

		# Use inclusive duration for bar width
		var end_offset_ms = start_offset_ms + inclusive_duration_ms

		# Calculate positions based on tracked duration
		var start_pos = int((start_offset_ms / duration_ms) * WATERFALL_LINE_WIDTH)
		var end_pos = int((end_offset_ms / duration_ms) * WATERFALL_LINE_WIDTH)
		var bar_width = max(1, end_pos - start_pos)

		# Name line with self and total time
		# Show microseconds if value is less than threshold
		var time_suffix = ""
		if inclusive_duration_ms != self_duration_ms:
			var self_str = ("%dµs" % area.duration_usec) if self_duration_ms < WATERFALL_USEC_THRESHOLD_MS else ("%.1fms" % self_duration_ms)
			var incl_str = ("%dµs" % inclusive_duration_usec) if inclusive_duration_ms < WATERFALL_USEC_THRESHOLD_MS else ("%.1fms" % inclusive_duration_ms)
			time_suffix = " (%s self, %s total)" % [self_str, incl_str]
		else:
			var dur_str = ("%dµs" % area.duration_usec) if self_duration_ms < WATERFALL_USEC_THRESHOLD_MS else ("%.1fms" % self_duration_ms)
			time_suffix = " (%s)" % dur_str

		# Add call count for deferred calls
		if tree_nodes.has(area.name) and tree_nodes[area.name].has("count"):
			var call_count = tree_nodes[area.name].count
			if call_count > 1:
				time_suffix += " x%d" % call_count

		var name_line = "       " + " ".repeat(start_pos) + area.name + time_suffix
		lines.push_back(name_line)

		# Bar line: "start_time spaces |--------| end_time"
		var bar_line = "%5.1fms " % start_offset_ms
		bar_line += " ".repeat(start_pos)
		bar_line += "|" + "-".repeat(max(0, bar_width - 2)) + "|"
		bar_line += " %.1fms" % end_offset_ms
		lines.push_back(bar_line)

	if filtered_areas.size() > WATERFALL_MAX_AREAS:
		lines.push_back("... and %d more areas" % (filtered_areas.size() - WATERFALL_MAX_AREAS))

	var result = "\n".join(lines)

	# Debug: Print the waterfall
	if OS.has_feature("editor"):
		print("=== WATERFALL ===")
		print(result)
		print("=================")

	return result
