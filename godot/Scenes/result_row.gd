@tool

extends HBoxContainer
class_name ResultRow

@export var duration: float = 0.3
@export var totalLabel: HighlightLabel = null
@export var currentLabel: Label = null
@export var was_best: bool = false : set = _set_was_best

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var color = get_theme_color( "font_color", "ResultLabel")
	#if color == null:
	#	push_error( "No font_color for ResultLabel")
	#	color = Color.MAGENTA
	#$TotalLabel.add_theme_color_override("font_color", color)
	_update_look()

func _set_was_best( b: bool ) -> void:
	var needs_update = was_best != b
	was_best = b
	if needs_update:
		print("needs_update")
		_update_look()

func _update_look() -> void:
	if totalLabel != null:
		totalLabel.highlighted = was_best
	
func _process(_delta: float) -> void:
	pass

func set_total( v: String ) -> void:
	totalLabel.text = v
	
func set_current( v: String ) -> void:
	currentLabel.text = v

func clear() -> void:
	totalLabel.text = ""
	currentLabel.text = ""
	self.was_best = false
	
