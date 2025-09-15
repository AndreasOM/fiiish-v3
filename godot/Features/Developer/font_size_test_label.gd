class_name FontSizeTestLabel
extends Label

@export var font_size: int = 8
# const ALL_THINGS_PINK = preload("res://Fonts/all_things_pink.ttf")
func _ready() -> void:
	self.text = "Font Size %d" % self.font_size
	self.add_theme_font_size_override("font_size", self.font_size)
	#self.add_theme_font_override("font", ALL_THINGS_PINK)
	self.theme_type_variation = "LabelHeader"
