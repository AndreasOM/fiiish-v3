extends Node

const NO_NEIGHBOR : NodePath = ""

@onready var _viewport : Viewport = get_viewport()

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event : InputEvent) -> void:
	var focus_owner : Control = _viewport.gui_get_focus_owner()
	if ( 
		false
		|| event.is_action_pressed("ui_focus_prev")
		|| event.is_action_pressed("ui_focus_next")
#		or event.is_action_pressed("ui_up")
#		or event.is_action_pressed("ui_down")
#		or event.is_action_pressed("ui_left")
#		or event.is_action_pressed("ui_right")
	):
		var new_focus_owner: Control = null
		var dir: String = ""
		# Always accept UI directional actions to prevent Godot from "guessing" the next target.
		_viewport.set_input_as_handled()
		if focus_owner != null:
			if event.is_action_pressed("ui_focus_prev") and focus_owner.focus_previous != NO_NEIGHBOR:
				dir = "prev"
				new_focus_owner = focus_owner.get_node(focus_owner.focus_previous)
			elif event.is_action_pressed("ui_focus_next") and focus_owner.focus_previous != NO_NEIGHBOR:
				dir = "next"
				new_focus_owner = focus_owner.get_node(focus_owner.focus_next)
#			elif event.is_action_pressed("ui_up") and focus_owner.focus_neighbor_top != NO_NEIGHBOR:
#				new_focus_owner = focus_owner.get_node(focus_owner.focus_neighbor_top)
#			elif event.is_action_pressed("ui_down") and focus_owner.focus_neighbor_bottom != NO_NEIGHBOR:
#				new_focus_owner = focus_owner.get_node(focus_owner.focus_neighbor_bottom)
#			elif event.is_action_pressed("ui_left") and focus_owner.focus_neighbor_left != NO_NEIGHBOR:
#				dir = "left"
#				new_focus_owner = focus_owner.get_node(focus_owner.focus_neighbor_left)
#			elif event.is_action_pressed("ui_right") and focus_owner.focus_neighbor_right != NO_NEIGHBOR:
#				new_focus_owner = focus_owner.get_node(focus_owner.focus_neighbor_right)

			if new_focus_owner != null:
				print("Focus: ! %s -(%s)> %s" % [focus_owner.name, dir, new_focus_owner.name])
				new_focus_owner.grab_focus()
			else:
				print("Focus: ! %s -(%s)> NONE" % [focus_owner.name, dir])
