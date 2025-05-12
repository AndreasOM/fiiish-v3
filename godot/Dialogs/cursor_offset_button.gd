class_name CursorOffsetButton
extends TextureButton

@export var cursor_offset: float = 0.0 : set = set_cursor_offset

@onready var rich_text_label: RichTextLabel = $RichTextLabel


func set_cursor_offset( o: float ) -> void:
	cursor_offset = o
	self._update_label()
	
func _update_label() -> void:
	self.rich_text_label.text = "CrsO:%3.0f" % self.cursor_offset
	
func _ready() -> void:
	self._update_label()
