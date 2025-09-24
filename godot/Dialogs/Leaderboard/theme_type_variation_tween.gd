# extends Control
class_name ThemeTypeVariationTween

var _tween: Tween = null

var _added_color_overrides: Dictionary[ String, bool ] = {}
var _added_constant_overrides: Dictionary[ String, bool ] = {}

func set_highlighted( 
	control: Control,
	tween: Tween,
	theme: Theme,
	variation_normal: StringName, 
	variation_highlighted: StringName,
	duration: float,
	highlighted: bool,
) -> bool:
	
	if _tween != null:
		_tween.kill()
	_tween = tween
	
	var variation = variation_normal
	if highlighted:
		variation = variation_highlighted

	var any_tweens = false
		
	var properties = get_theme_property_list_for_variations(
		theme,
		[ variation_normal, variation_highlighted ]
	)
		
	for property in properties:
		# print( property )
		any_tweens = self.tween_property(
			control,
			theme,
			property,
			tween,
			variation,
			duration
		) || any_tweens
		tween.set_parallel( true )
	
	if !any_tweens:
		tween.kill()
		
	tween.set_parallel( false )
	tween.tween_callback( self.cleanup.bind( control, variation_normal, variation_highlighted, highlighted ) )
	
	return any_tweens

func get_theme_property_list_for_variations( theme: Theme, variations: Array[ StringName ] ) -> Array[ NodePath ]:
	var properties: Array[ NodePath ] = []
	
	for variation in variations:
		var p = get_theme_property_list( theme, variation )
		properties.append_array( p )
	
	return properties
		
func get_theme_property_list( theme: Theme, variation: StringName ) -> Array[ NodePath ]:
	var properties: Array[ NodePath ] = []

	var colors = theme.get_color_list( variation )
	for color in colors:
		properties.push_back( NodePath( "/".join(["theme_override_colors",color]) ) )
		
	var constants = theme.get_constant_list( variation )
	for constant in constants:
		properties.push_back( NodePath( "/".join(["theme_override_constants",constant]) ) )
		
	return properties
	
func tween_property( 
	control: Control,
	theme: Theme,
	path: NodePath,
	tween: Tween, 
	variation: StringName, 
	duration: float,
) -> bool:
	var type = path.get_name(0)
	match type:
		"theme_override_colors":
			return self.tween_color_property(
				control,
				theme,
				path,
				tween,
				variation,
				duration,
			)
		"theme_override_constants":
			return self.tween_constant_property(
				control,
				theme,
				path,
				tween,
				variation,
				duration,
			)
		_:
			# unknown type
			pass
	return false
	
func tween_color_property( 
	control: Control,
	theme: Theme,
	path: NodePath,
	tween: Tween, 
	variation: StringName, 
	duration: float,
) -> bool:
	# print( "Tweening [color] %s" % [ path ])
	var name = path.get_name(1)
	var current_color = control.get_theme_color( name )
	control.remove_theme_color_override( name )
	# var original_color = control.get_theme_color( "font_color", variation_normal)
	
	# var has_color = theme.has_color( "font_color", variation )
	var colors = theme.get_color_list( variation )
	# print( colors )
	#var has_color = colors.has( name )
	#if has_color:
		#var color = control.get_theme_color( name, variation)
		#control.add_theme_color_override(name, current_color)
		#tween.tween_property(control, path, color, duration)
		## print( "Tweening [color] %s (%s) to %s" % [ name, variation, color ])
		#return true
	#else:
		## print("WARN: no color for %s" %[ path ])
		#control.remove_theme_color_override( name )
		#return false

	var color = control.get_theme_color( name, variation)
	control.add_theme_color_override(name, current_color)
	self._added_color_overrides[ name ] = true
	tween.tween_property(control, path, color, duration)
	# print( "Tweening [color] %s (%s) to %s" % [ name, variation, color ])
	return true

func tween_constant_property( 
	control: Control,
	theme: Theme,
	path: NodePath,
	tween: Tween, 
	variation: StringName, 
	duration: float,
) -> bool:
	# print( "Tweening [constant] %s" % [ path ])
	var name = path.get_name(1)
	var current_constant = control.get_theme_constant( name )
	control.remove_theme_constant_override( name )
	
	var constants = theme.get_constant_list( variation )
	# print( constants )
	#var has_constant = constants.has( name )
	#if has_constant:
		#var constant = control.get_theme_constant( name, variation)
		#control.add_theme_constant_override(name, current_constant)
		#tween.tween_property(control, path, constant, duration)
		## print( "Tweening [constant] %s (%s) to %s" % [ name, variation, constant ])
		#return true
	#else:
		## print("WARN: no constant for %s" %[ path ])
		#control.remove_theme_constant_override( name )
		#return false

	var constant = control.get_theme_constant( name, variation)
	control.add_theme_constant_override(name, current_constant)
	self._added_constant_overrides[ name ] = true
	tween.tween_property(control, path, constant, duration)
	# print( "Tweening [constant] %s (%s) to %s" % [ name, variation, constant ])
	return true

func cleanup(
	control: Control,
	variation_normal: StringName, 
	variation_highlighted: StringName,
	highlighted: bool,
) -> void:
	# print("Cleanup")
	var variation = variation_normal
	if highlighted:
		variation = variation_highlighted
		
	control.theme_type_variation = variation
	
	for co in self._added_color_overrides.keys():
		control.remove_theme_color_override( co )

	self._added_color_overrides.clear()

	for co in self._added_constant_overrides.keys():
		control.remove_theme_constant_override( co )
		
	self._added_constant_overrides.clear()
