class_name ZoneSelectionElement
extends MarginContainer

signal selected

@export var title: String = ""
@export var filename: String = ""
@export var difficulty: int = -1

@onready var title_rich_text_label: RichTextLabel = %TitleRichTextLabel
@onready var filename_rich_text_label: RichTextLabel = %FilenameRichTextLabel
@onready var difficulty_rich_text_label: RichTextLabel = %DifficultyRichTextLabel

func _ready() -> void:
	self.title_rich_text_label.text = self.title
	self.filename_rich_text_label.text = self.filename
	self.difficulty_rich_text_label.text = "%d" % self.difficulty
	
func _on_texture_button_pressed() -> void:
	self.selected.emit( self )
