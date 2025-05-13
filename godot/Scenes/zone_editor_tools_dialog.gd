class_name ZoneEditorToolsDialog
extends Dialog

signal tool_selected( tool_id: ZoneEditorToolIds.Id )

@onready var buttons: VBoxContainer = %Buttons

func _ready() -> void:
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
