extends CenterContainer
class_name ToggleButtonContainer

@export var toggle_duration: float = 0.3
#@export var button_a: FadeableContainer
#@export var button_b: FadeableContainer

var button_a: FadeableContainer = null
var button_b: FadeableContainer = null

enum ToggleState {
	A,
	B,
	None,
}

signal toggled( ToggleState )

	
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

func goto_a():
	button_a.fade_in( toggle_duration )
	button_b.fade_out( toggle_duration )

func goto_b():
	button_a.fade_out( toggle_duration )
	button_b.fade_in( toggle_duration )

func _on_a_pressed():
	print("A")
	goto_b()
	toggled.emit(ToggleState.B)

func _on_b_pressed():
	print("B")
	goto_a()
	toggled.emit(ToggleState.A)
