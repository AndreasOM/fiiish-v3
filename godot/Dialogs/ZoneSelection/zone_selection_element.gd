class_name ZoneSelectionElement
extends MarginContainer

signal selected

@export var title: String = ""
@export var filename: String = ""

@onready var title_rich_text_label: RichTextLabel = %TitleRichTextLabel
@onready var filename_rich_text_label: RichTextLabel = %FilenameRichTextLabel

func _ready() -> void:
	self.title_rich_text_label.text = self.title
	self.filename_rich_text_label.text = self.filename
	
func _on_texture_button_pressed() -> void:
	self.selected.emit( self )
