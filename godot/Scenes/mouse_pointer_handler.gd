class_name MousePointerHandler
extends Node

var _is_mouse_pointer_inside: bool = true
var _is_mouse_pointer_hidden: bool = false

func _process(_delta: float) -> void:
	if self._is_mouse_pointer_inside:
		if Input.is_anything_pressed():
			if Input.get_mouse_button_mask() == 0:
				self._hide_mouse_pointer()

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
#		print("[Input] enter")
		self._is_mouse_pointer_inside = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
#		print("[Input] exit")
		self._is_mouse_pointer_inside = false
		self._show_mouse_pointer()
		
func _input(event: InputEvent) -> void:
#	if event is InputEventAction:
		# self._hide_mousepointer()
#		pass
	if event is InputEventMouse:
		self._show_mouse_pointer()

func _show_mouse_pointer() -> void:
	if !self._is_mouse_pointer_hidden:
		return
		
#	print("[Input] Showing mousepointer")
	self._is_mouse_pointer_hidden = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _hide_mouse_pointer() -> void:
	if self._is_mouse_pointer_hidden:
		return
		
#	print("[Input] Hiding mousepointer")
	self._is_mouse_pointer_hidden = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
