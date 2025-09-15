extends Control
@onready var font_size_test_v_box_container: VBoxContainer = %FontSizeTestVBoxContainer


func _ready() -> void:
	const SIZES = [ 8, 16, 32, 64, 128, 256 ]
	
	for c in self.font_size_test_v_box_container.get_children():
		c.get_parent().remove_child( c )
		c.queue_free()

	var s = 8
	while s<128:
	#for s in SIZES:
		var l = FontSizeTestLabel.new()
		l.font_size = s
		l.name = "FontSizeTestLabel-%d" % s
		l.add_theme_constant_override("outline_size", 8)
		self.font_size_test_v_box_container.add_child( l )
		s *= 1.2
