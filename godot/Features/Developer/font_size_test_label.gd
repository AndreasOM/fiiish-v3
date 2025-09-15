class_name FontSizeTestLabel
extends Label

@export var font_size: int = 8

func _ready() -> void:
	self.text = "Font Size %d" % self.font_size
	#self.theme_override_font_sizes.font_size = self.font_size
	self.add_theme_font_size_override("font_size", self.font_size)
