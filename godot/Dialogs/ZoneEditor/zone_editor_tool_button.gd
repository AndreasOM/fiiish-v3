class_name ZoneEditorToolButton
extends CenterContainer

signal selected( tool_button: ZoneEditorToolButton)

@export var tool_id: ZoneEditorToolIds.Id = ZoneEditorToolIds.Id.SELECT
@export var label: String = "" : set = set_label
@onready var label_a: Label = %LabelA
@onready var label_b: Label = %LabelB
@onready var toggle_button_container: ToggleButtonContainer = %ToggleButtonContainer

enum State {
	ACTIVE,
	INACTIVE,
}

var _state: State = State.INACTIVE

func set_label( v: String ) -> void:
	label = v
	if self.label_a != null:
		self.label_a.text = self.label
	if self.label_b != null:
		self.label_b.text = self.label
	
func make_active() -> void:
	self._state = State.ACTIVE
	self._update_state()

func make_inactive() -> void:
	self._state = State.INACTIVE
	self._update_state()
	
func _ready() -> void:
	self.label_a.text = self.label
	self.label_b.text = self.label
	self._update_state()

func _update_state() -> void:
	match self._state:
		State.ACTIVE:
			self.toggle_button_container.goto_a()
		State.INACTIVE:
			self.toggle_button_container.goto_b()
			
	
	


func _on_toggle_button_container_toggled(state:ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			self.selected.emit( self )
		_:
			pass
