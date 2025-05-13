class_name ZoneEditorToolsDialog
extends Dialog

signal tool_selected( tool_id: ZoneEditorToolIds.Id )
signal undo_pressed()

@onready var tool_buttons: VBoxContainer = %ToolButtons
@onready var undo_button: TextureButton = %UndoButton

var last_selected_tool_id: ZoneEditorToolIds.Id = ZoneEditorToolIds.Id.SELECT
func _ready() -> void:
	self._update_buttons( self.last_selected_tool_id  )
	self.tool_selected.emit( self.last_selected_tool_id )
	self.undo_button.disabled = true
	
func _update_buttons( active_tid: ZoneEditorToolIds.Id ) -> void:
	for c in self.tool_buttons.get_children():
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
	self.last_selected_tool_id = tool_button.tool_id
	self._update_buttons( self.last_selected_tool_id )
	self.tool_selected.emit( self.last_selected_tool_id )

func _on_undo_button_pressed() -> void:
	self.undo_pressed.emit()
	var new_size = self._dialog_manager.game.zone_editor_command_history_size()
	self.undo_button.disabled = new_size == 0
		
func on_command_history_size_changed( new_size: int ) -> void:
#	print("History size: %d" % new_size)
	self.undo_button.disabled = new_size == 0
