class_name DeveloperOverlayDialog
extends Dialog

@onready var debug_rich_text_label: RichTextLabel = %DebugRichTextLabel
@onready var buttons_rich_text_label: RichTextLabel = %ButtonsRichTextLabel
@onready var entity_stats_rich_text_label: RichTextLabel = %EntityStatsRichTextLabel
@onready var performance_stats_rich_text_label: RichTextLabel = %PerformanceStatsRichTextLabel

var _debug_lines: Array[ String ] = []
var _buttons: Dictionary[ String, bool ] = {}

const PERF_STATS_UPDATE_INTERVAL = 60
var _perf_stats_frame_counter: int = 0

func _ready() -> void:
	Events.developer_message.connect( _on_developer_message )
	

func _on_developer_message( msg: DeveloperMessage ) -> void:
	print( msg )
	if msg is DeveloperMessageDebug:
		var dbg = msg as DeveloperMessageDebug
		print_rich("[color=orange]Debug: %s[/color]" % dbg.text)
		self._debug_lines.push_back( dbg.text )
		self._update_debug()
	elif msg is DeveloperMessageButtonChange:
		var btn = msg as DeveloperMessageButtonChange
		# print_rich("[color=orange]Debug: %s[/color]" % msg.to_string())
		self._buttons[ btn.name ] = btn.pressed
		self._update_buttons()
	else:
		self._debug_lines.push_back( "Unhandled DeveloperMessage %s" % msg.to_string() )
		print_rich("[color=red]Debug: %s[/color]" % msg.to_string())
		self._update_debug()
		pass
		
func _update_buttons() -> void:
	if self.buttons_rich_text_label != null:
		var button_lines = []
		for n in self._buttons:
			var p = self._buttons[ n ]
			button_lines.push_back( "%d <- %s" % [ int(p), n ])
		var joined = "\n".join(button_lines)
		self.buttons_rich_text_label.text = joined
	
func _update_debug() -> void:
	while self._debug_lines.size() > 20:
		self._debug_lines.pop_front()
	if self.debug_rich_text_label != null:
		var joined = "\n".join(_debug_lines)
		self.debug_rich_text_label.text = joined

func _process(_delta: float) -> void:
	_update_entity_stats()
	_update_performance_stats()

func _update_entity_stats() -> void:
	if self.entity_stats_rich_text_label == null:
		return
	if self._dialog_manager == null:
		return
	if self._dialog_manager.game == null:
		return

	var game_manager = self._dialog_manager.game.game_manager
	if game_manager == null:
		return

	var stats = game_manager.entity_stats
	var stats_dict = stats.to_dict()
	if !stats_dict.is_empty():
		self.entity_stats_rich_text_label.text = str(stats)

func _update_performance_stats() -> void:
	if self.performance_stats_rich_text_label == null:
		return

	self._perf_stats_frame_counter += 1
	if self._perf_stats_frame_counter < PERF_STATS_UPDATE_INTERVAL:
		return

	self._perf_stats_frame_counter = 0

	var all_stats = PerformanceMonitor.get_all_stats()
	if all_stats.is_empty():
		return

	var area_names = PerformanceMonitor.get_all_area_names()
	area_names.sort()

	var lines: Array[String] = []
	for area_name in area_names:
		var stats = all_stats[area_name]
		if stats != null:
			lines.push_back(str(stats))

	self.performance_stats_rich_text_label.text = "\n".join(lines)

static func is_developer() -> bool:
	var developer_enabled = false
	if FeatureTags.has_feature("editor_runtime"):
		developer_enabled = true
	
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		if steam.isSteamRunning():
			var steam_id = steam.getSteamID()
			var developer_ids = [
				76561199172150142, # andreas OM
			]
			if developer_ids.find( steam_id ) >= 0:
				developer_enabled = true
		
	return developer_enabled
