extends HBoxContainer
class_name ResultRow

@export var totalLabel: Label = null
@export var currentLabel: Label = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func setTotal( v: String ):
	totalLabel.text = v
	
func setCurrent( v: String ):
	currentLabel.text = v

func clear():
	totalLabel.text = ""
	currentLabel.text = ""
	
