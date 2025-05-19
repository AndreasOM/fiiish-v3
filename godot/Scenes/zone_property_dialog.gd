class_name ZonePropertyDialog
extends Dialog

signal zone_name_submitted( new_name: String )
signal difficulty_changed( difficulty: int )
signal zone_width_changed( width: int )

@export var zone_editing_enabled: bool = true : set = set_zone_editing_enabled
@export var stop_testing_enabled: bool = false : set = set_stop_testing_enabled
@onready var stop_testing_button: TextureButton = %StopTestingButton
@onready var name_line_edit: LineEdit = %NameLineEdit
@onready var difficulty_value_label: Label = %DifficultyValueLabel
@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var width_line_edit: LineEdit = %WidthLineEdit

func set_zone_editing_enabled( v: bool ) -> void:
	zone_editing_enabled = v
	self.name_line_edit.editable = zone_editing_enabled
	self.difficulty_slider.editable = zone_editing_enabled
	self.width_line_edit.editable = zone_editing_enabled
	
func set_stop_testing_enabled( v: bool ) -> void:
	stop_testing_enabled = v
	self._update_stop_testing_button()
	
	
func _update_stop_testing_button() -> void:
	if self.stop_testing_button == null:
		return
	self.stop_testing_button.visible = self.stop_testing_enabled
	
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


func _on_stop_testing_button_pressed() -> void:
	self._dialog_manager.game.goto_zone_editor()


func _on_name_line_edit_text_submitted(new_text: String) -> void:
	self.zone_name_submitted.emit( new_text )

func on_zone_name_changed( zone_name: String ) -> void:
	self.name_line_edit.text = zone_name


func _on_difficulty_slider_value_changed(difficulty: float) -> void:
	self.difficulty_value_label.text = "%d" % difficulty

func _on_difficulty_slider_drag_ended(value_changed: bool) -> void:
	if !value_changed:
		return
	
	var v = int(self.difficulty_slider.value)
	self.difficulty_changed.emit( v )

func on_zone_difficulty_changed( difficulty: int ) -> void:
	self.difficulty_value_label.text = "%d" % difficulty
	self.difficulty_slider.value = difficulty


func _on_width_line_edit_text_submitted(new_text: String) -> void:
	if !new_text.is_valid_int():
		# :TODO: tell user?
		return
	var f = int(new_text)
	self.zone_width_changed.emit( f )
	
func on_zone_width_changed( width: int ) -> void:
	self.width_line_edit.text = "%d" % width
	
