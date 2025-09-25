class_name DeveloperOverlayDialog
extends Dialog

@onready var debug_rich_text_label: RichTextLabel = %DebugRichTextLabel

var _debug_lines: Array[ String ] = []

func _ready() -> void:
	Events.developer_message.connect( _on_developer_message )
	pass
	

func _on_developer_message( msg: DeveloperMessage ) -> void:
	print( msg )
	if msg is DeveloperMessageDebug:
		var dbg = msg as DeveloperMessageDebug
		self._debug_lines.push_back( dbg.text )
		self._update_debug()
	else:
		self._debug_lines.push_back( "Unhandled DeveloperMessage %s" % msg.to_string() )
		self._update_debug()
		pass
		
func _update_debug() -> void:
	while self._debug_lines.size() > 20:
		self._debug_lines.pop_front()
	if self.debug_rich_text_label != null:
		var joined = "\n".join(_debug_lines)
		self.debug_rich_text_label.text = joined
	
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
