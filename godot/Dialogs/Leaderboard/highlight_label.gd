@tool

extends Label
class_name HighlightLabel

@export var variation_normal: StringName = ""
@export var variation_highlighted: StringName = ""
@export var highlighted: bool = false : set = set_highlighted
@export var transition_duration: float = 0.6


func _ready():
	var color = get_theme_color( "font_color", variation_normal)
	if color == null:
		push_error( "No font_color for Normal Variation")
		color = Color.MAGENTA
	print("?!? %s -> %s" % [ variation_normal, color ])
	self.add_theme_color_override("font_color", color)
	_update_look()

func set_highlighted( h: bool ):
	highlighted = h	
	if get_tree() != null:
		_update_look()


func _update_look():
	if highlighted:
		var color = get_theme_color( "font_color", variation_highlighted)
		var tree = get_tree()
		if color != null && tree != null:
			print("??? %s -> %s" % [ variation_highlighted, color ])
			var tween = tree.create_tween()
			tween.tween_property(self, "theme_override_colors/font_color", color, self.transition_duration).set_trans(Tween.TRANS_BOUNCE)
	else:
		self.remove_theme_color_override("font_color")
		var color = get_theme_color( "font_color", variation_normal)
		self.add_theme_color_override("font_color", color)
