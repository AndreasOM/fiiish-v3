extends HBoxContainer
class_name ResultRow

@export var duration: float = 0.3
@export var totalLabel: Label = null
@export var currentLabel: Label = null
@export var was_best: bool = false : set = _set_was_best

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color = get_theme_color( "font_color", "ResultLabel")
	if color == null:
		push_error( "No font_color for ResultLabel")
		color = Color.MAGENTA
	$TotalLabel.add_theme_color_override("font_color", color)
	_update_look()

func _set_was_best( b: bool ):
	was_best = b
	_update_look()

func _update_look():
	$TotalLabel.theme_type_variation = "ResultLabel"
	if was_best:
		var color = get_theme_color( "font_color", "BestResultLabel")
		if color != null:
			var tween = get_tree().create_tween()
			tween.tween_property($TotalLabel, "theme_override_colors/font_color", color, duration).set_trans(Tween.TRANS_BOUNCE)
		# $TotalLabel.theme_type_variation = "BestResultLabel"
		# $TotalLabel.theme_type_variation = "ResultLabel"
	# else:
		# $TotalLabel.theme_type_variation = "ResultLabel"
	
func _process(_delta: float) -> void:
	pass

func setTotal( v: String ):
	totalLabel.text = v
	
func setCurrent( v: String ):
	currentLabel.text = v

func clear():
	totalLabel.text = ""
	currentLabel.text = ""
	self.was_best = false
	
