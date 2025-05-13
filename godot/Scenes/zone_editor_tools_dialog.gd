class_name ZoneEditorToolsDialog
extends Dialog

signal tool_selected( tool_id: ZoneEditorToolIds.Id )

@onready var delete_zone_editor_tool_button: ZoneEditorToolButton = %DeleteZoneEditorToolButton
@onready var move_zone_editor_tool_button: ZoneEditorToolButton = %MoveZoneEditorToolButton
@onready var spawn_zone_editor_tool_button: ZoneEditorToolButton = %SpawnZoneEditorToolButton
@onready var select_zone_editor_tool_button: ZoneEditorToolButton = %SelectZoneEditorToolButton
@onready var buttons: VBoxContainer = %Buttons

#var _tool_buttons: Dictionary[ ZoneEditorToolIds.Id, ZoneEditorToolButton ] = {}
func _ready() -> void:
#	_tool_buttons[ZoneEditorToolIds.Id.DELETE] = self.delete_zone_editor_tool_button
#	_tool_buttons[ZoneEditorToolIds.Id.MOVE] = self.move_zone_editor_tool_button
#	_tool_buttons[ZoneEditorToolIds.Id.SPAWN] = self.spawn_zone_editor_tool_button
#	_tool_buttons[ZoneEditorToolIds.Id.SELECT] = self.select_zone_editor_tool_button
	
#	for tb in self._tool_buttons.values():
#		tb.make_inactive()

#	self._tool_buttons[ ZoneEditorToolIds.Id.SELECT ].make_active()

	self._update_buttons( ZoneEditorToolIds.Id.SELECT )

func _update_buttons( active_tid: ZoneEditorToolIds.Id ) -> void:
	for c in self.buttons.get_children():
		var b = c as ZoneEditorToolButton
		if b == null:
			continue
		if b.tool_id == active_tid:
			b.make_active()
		else:
			b.make_inactive()
	
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
	var selected_tid = tool_button.tool_id
	self._update_buttons( selected_tid )
	self.tool_selected.emit( selected_tid )
