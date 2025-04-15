@tool

extends Label
class_name HighlightLabel

#@export var variation_normal: StringName = ""
#@export var variation_highlighted: StringName = ""

@export var highlighted: bool = false : set = set_highlighted

# @export_group( "Theme Type Variations", "variation" )

var variation_normal: StringName = "" : set = set_variation_normal
var variation_highlighted: StringName = "" : set = set_variation_highlighted
var transition_duration: float = 0.6

func set_variation_normal( v: StringName ):
	variation_normal = v
	if !highlighted:
		_update_look()

func set_variation_highlighted( v: StringName ):
	variation_highlighted = v
	if highlighted:
		_update_look()

func _get_preferred_theme() -> Theme:
	var t = get_theme()
	if t != null:
		return t

	var p = ProjectSettings.get_setting("gui/theme/custom")
	if p is String && p != "":
		var theme = load(p) as Theme
		if theme != null:
			return theme
			
	return EditorInterface.get_editor_theme()
	
func _get_property_list() -> Array[Dictionary]:
	var theme = _get_preferred_theme()
	var variations = theme.get_type_variation_list( "Label" )
	return [
		{
			name = "transition_duration",
			type = TYPE_FLOAT,
			#hint = PROPERTY_HINT_ENUM,
			hint_string = "0.6",
			usage = PROPERTY_USAGE_DEFAULT,
		},
		{
			name = "Theme Type Variations",
			type = TYPE_STRING,
			# usage = PROPERTY_USAGE_GROUP,
			usage = PROPERTY_USAGE_CATEGORY,
			hint_string = "variation"
		},
		{
			name = "variation_normal",
			type = TYPE_STRING_NAME,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(variations),
			usage = PROPERTY_USAGE_DEFAULT,
		},
		{
			name = "variation_highlighted",
			type = TYPE_STRING_NAME,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(variations),
			usage = PROPERTY_USAGE_DEFAULT,
		},
	]
	
func _ready():
	var color = get_theme_color( "font_color", variation_normal)
	if color == null:
		push_error( "No font_color for Normal Variation")
		color = Color.MAGENTA
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
			var tween = tree.create_tween()
			tween.tween_property(self, "theme_override_colors/font_color", color, self.transition_duration).set_trans(Tween.TRANS_BOUNCE)
	else:
		self.remove_theme_color_override("font_color")
		var color = get_theme_color( "font_color", variation_normal)
		self.add_theme_color_override("font_color", color)
