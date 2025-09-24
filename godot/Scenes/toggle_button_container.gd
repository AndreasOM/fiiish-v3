extends CenterContainer
class_name ToggleButtonContainer

enum ToggleMode {
	AUTO,
	REQUEST,
}

@export var toggle_duration: float = 0.3
@export var toggle_mode: ToggleMode = ToggleMode.AUTO

#@export var button_a: FadeableContainer
#@export var button_b: FadeableContainer

var button_a: FadeableContainer = null
var button_b: FadeableContainer = null

enum ToggleState {
	A,
	B,
	None,
}

var _toggle_state: ToggleState = ToggleState.None


signal toggled( state: ToggleState )
signal toggle_requested( state: ToggleState )

	
func _ready() -> void:
	var children = get_children()
	if children.size() != 2:
		push_error( "%s ToggleButtonContainer needs exactly two children! But has %d" % [ name, children.size() ])
		return
		
	var c0 = children[ 0 ] as FadeableContainer
	if c0 == null:
		push_error("%s First child of ToggleButtonContainer is not a FadeableContainer" % name)
		return

	var c1 = children[ 1 ] as FadeableContainer
	if c1 == null:
		push_error("%s Second child of ToggleButtonContainer is not a FadeableContainer" % name)
		return
	
	button_a = c0
	button_b = c1
	button_a.fade_in( 0.0 )
	button_b.fade_out( 0.0 )

func goto_a() -> void:
	button_a.fade_in( toggle_duration )
	button_b.fade_out( toggle_duration )
	self._toggle_state = ToggleState.A

func goto_b() -> void:
	button_a.fade_out( toggle_duration )
	button_b.fade_in( toggle_duration )
	self._toggle_state = ToggleState.B

func _on_a_pressed() -> void:
	print("A pressed")
	match self.toggle_mode:
		ToggleMode.AUTO:
			goto_b()
			self.button_b.grab_focus.call_deferred()
			toggled.emit(ToggleState.B)
		ToggleMode.REQUEST:
			self.toggle_requested.emit( ToggleState.A )

func _on_b_pressed() -> void:
	print("B pressed")
	match self.toggle_mode:
		ToggleMode.AUTO:
			goto_a()
			self.button_a.grab_focus.call_deferred()
			toggled.emit(ToggleState.A)
		ToggleMode.REQUEST:
			self.toggle_requested.emit( ToggleState.A )
			


func _on_focus_entered() -> void:
	match self._toggle_state:
		ToggleState.A:
			if self.button_a.focus_mode != FocusMode.FOCUS_NONE:
				self.button_a.grab_focus.call_deferred()
		ToggleState.B:
			if self.button_b.focus_mode != FocusMode.FOCUS_NONE:
				self.button_b.grab_focus.call_deferred()
