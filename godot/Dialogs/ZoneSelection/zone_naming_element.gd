class_name ZoneNamingElement
extends MarginContainer

signal named

@export var title: String = ""
@export var filename: String = ""

@onready var title_rich_text_label: RichTextLabel = %TitleRichTextLabel
@onready var filename_line_edit: LineEdit = %FilenameLineEdit

func _ready() -> void:
	self.title_rich_text_label.text = self.title
	self.filename_line_edit.text = self.filename
	


func _on_filename_line_edit_text_submitted(new_filename: String) -> void:
	self.filename = new_filename
	self.named.emit( self )
