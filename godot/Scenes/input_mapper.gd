class_name InputMapper
extends Node


const MAPPINGS: Dictionary[ String, String ] = {
	"Menu_Confirm":	"ui_accept",
	"Menu_Cancel":	"ui_cancel",
	"Menu_Down":	"ui_down",
	"Menu_Up":		"ui_up",
	"Menu_Left":	"ui_left",
	"Menu_Right":	"ui_right",
	"Menu_Next":	"ui_focus_next",
	"Menu_Prev":	"ui_focus_prev",
}

func _input(event: InputEvent) -> void:
	for i in self.MAPPINGS:
		if event.is_action( i ):
			var o = self.MAPPINGS[ i ]
			if o != "":
				var ev = InputEventAction.new()
				ev.action = o
				ev.pressed = event.pressed
				Input.parse_input_event(ev)
