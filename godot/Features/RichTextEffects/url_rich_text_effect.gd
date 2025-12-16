@tool
class_name UrlRichTextEffect
extends RichTextEffect

var bbcode = "blue"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = Color(0.475, 0.689, 0.974, 1.0)
	return true
