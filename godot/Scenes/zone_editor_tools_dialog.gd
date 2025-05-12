class_name ZoneEditorToolsDialog
extends Dialog

@onready var delete_zone_editor_tool_button: ZoneEditorToolButton = %DeleteZoneEditorToolButton
@onready var move_zone_editor_tool_button: ZoneEditorToolButton = %MoveZoneEditorToolButton
@onready var spawn_zone_editor_tool_button: ZoneEditorToolButton = %SpawnZoneEditorToolButton
@onready var select_zone_editor_tool_button: ZoneEditorToolButton = %SelectZoneEditorToolButton

var _tool_buttons: Array[ ZoneEditorToolButton ] = []
func _ready() -> void:
	_tool_buttons.push_back( self.delete_zone_editor_tool_button )
	_tool_buttons.push_back( self.move_zone_editor_tool_button )
	_tool_buttons.push_back( self.spawn_zone_editor_tool_button )
	_tool_buttons.push_back( self.select_zone_editor_tool_button )
	
	for tb in self._tool_buttons:
			tb.make_inactive()

	self.select_zone_editor_tool_button.make_active()	
	
func open( duration: float):
	fade_in( duration )

func close( duration: float):
	fade_out( duration )

func toggle( duration: float ):
	toggle_fade( duration )

func toggle_fade( duration: float ):
	%FadeablePanelContainer.toggle_fade( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )

func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()


func _on_zone_editor_tool_button_selected(tool_button: ZoneEditorToolButton) -> void:
	for tb in self._tool_buttons:
		if tb != tool_button:
			tb.make_inactive()
