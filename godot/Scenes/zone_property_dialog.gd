class_name ZonePropertyDialog
extends FiiishDialog

signal zone_name_submitted( new_name: String )
signal difficulty_changed( difficulty: int )
signal zone_width_changed( width: int )

@export var zone_editing_enabled: bool = true : set = set_zone_editing_enabled
@export var stop_testing_enabled: bool = false : set = set_stop_testing_enabled
@onready var stop_testing_button: TextureButton = %StopTestingButton
@onready var name_line_edit: LineEdit = %NameLineEdit
@onready var difficulty_value_label: Label = %DifficultyValueLabel
@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var never_pick_check_box: CheckBox = %NeverPickCheckBox
@onready var width_line_edit: LineEdit = %WidthLineEdit

# Raw u16 difficulty of the zone, including the never-pick bit (see NewZone).
var _difficulty: int = 0

func set_zone_editing_enabled( v: bool ) -> void:
	zone_editing_enabled = v
	self.name_line_edit.editable = zone_editing_enabled
	self.width_line_edit.editable = zone_editing_enabled
	self._update_difficulty_widgets()
	
func set_stop_testing_enabled( v: bool ) -> void:
	stop_testing_enabled = v
	self._update_stop_testing_button()
	
	
func _update_stop_testing_button() -> void:
	if self.stop_testing_button == null:
		return
	self.stop_testing_button.visible = self.stop_testing_enabled

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
	
	# The slider is disabled while never-pick is set, so the bit is clear here.
	var v = int(self.difficulty_slider.value)
	self._difficulty = v
	self.difficulty_changed.emit( v )

func _on_never_pick_check_box_toggled( toggled_on: bool ) -> void:
	var d = NewZone.difficulty_with_never_pick( self._difficulty, toggled_on )
	if !toggled_on:
		# Unchecking only clears the bit. Keep what is left inside the slider range
		# (an old 65535 would otherwise stay at 32767).
		d = clampi( d, int(self.difficulty_slider.min_value), int(self.difficulty_slider.max_value) )
	self._difficulty = d
	self._update_difficulty_widgets()
	self.difficulty_changed.emit( d )

func on_zone_difficulty_changed( difficulty: int ) -> void:
	self._difficulty = difficulty
	self._update_difficulty_widgets()

func _update_difficulty_widgets() -> void:
	var never_pick = NewZone.difficulty_is_never_pick( self._difficulty )
	var shown = NewZone.difficulty_with_never_pick( self._difficulty, false )
	shown = clampi( shown, int(self.difficulty_slider.min_value), int(self.difficulty_slider.max_value) )
	self.difficulty_slider.set_value_no_signal( shown )
	self.difficulty_slider.editable = self.zone_editing_enabled && !never_pick
	self.difficulty_value_label.text = "never" if never_pick else "%d" % shown
	self.never_pick_check_box.set_pressed_no_signal( never_pick )
	self.never_pick_check_box.disabled = !self.zone_editing_enabled

func _on_width_line_edit_text_submitted(new_text: String) -> void:
	if !new_text.is_valid_int():
		# :TODO: tell user?
		return
	var f = int(new_text)
	self.zone_width_changed.emit( f )
	
func on_zone_width_changed( width: int ) -> void:
	self.width_line_edit.text = "%d" % width
