@tool

extends Label
class_name HighlightLabel

@export var highlighted: bool = false : set = set_highlighted

var variation_normal: StringName = "" : set = set_variation_normal
var variation_highlighted: StringName = "" : set = set_variation_highlighted
var transition_duration: float = 0.6

@onready var tween: ThemeTypeVariationTween = ThemeTypeVariationTween.new()

func set_variation_normal( v: StringName ) -> void:
	variation_normal = v
	if !highlighted:
		_update_look()

func set_variation_highlighted( v: StringName ) -> void:
	variation_highlighted = v
	if highlighted:
		_update_look()

func _get_preferred_theme() -> Theme:
	var t = get_theme()
	if t != null:
		return t

	var p = ProjectSettings.get_setting("gui/theme/custom")
	if p is String && p != "":
		var t2 = load(p) as Theme
		if t2 != null:
			return t2

	#if Engine.is_editor_hint():
	#	return EditorInterface.get_editor_theme()
	
	push_warning("No theme found for %s" % self.name )	
	return null
	
func _get_property_list() -> Array[Dictionary]:
	var t = _get_preferred_theme()
	var variations = t.get_type_variation_list( "Label" )
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
	
func _ready() -> void:
	_update_look()

func set_highlighted( h: bool ) -> void:
	highlighted = h
	if is_inside_tree():
	# if get_tree() != null:
		_update_look()

func _update_look() -> void:
	if !is_inside_tree():
		#push_warning("Not inside tree")
		return
		
	var tree = get_tree()
	var ttheme = _get_preferred_theme()
	
	if tree != null && self.tween != null:
		var t = tree.create_tween()
		t.set_trans( Tween.TRANS_SPRING )
		t.set_ease( Tween.EASE_IN_OUT )
		self.tween.set_highlighted(
			self,
			t,
			ttheme,
			self.variation_normal,
			self.variation_highlighted,
			self.transition_duration,
			self.highlighted
		)
