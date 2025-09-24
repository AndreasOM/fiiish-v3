@tool
extends MarginContainer
class_name MainMenuEntry

enum Id {
	NONE,
	LEADERBOARD,
	GAME_MODE,
	ZONE_EDITOR,
	CREDITS,
	QUIT,
	ACHIEVEMENTS,
	ABOUT_DEMO,
	DEVELOPER,
}

enum State {
	HIDDEN,
	DISABLED,
	ENABLED,
}

@export var id: Id = Id.NONE
@export var state: State = State.ENABLED : set = _set_state
@export var label: String = "" : set = _set_label


@export_group("Texture", "texture")
@export var texture_normal: Texture2D = null
@export var texture_disabled: Texture2D = null
@export var texture_focused: Texture2D = null

@export var focus_duration: float = 0.33

signal pressed

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var texture_button: TextureButton = %TextureButton
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _set_state( s: State ) -> void:
	state = s
	self._update()
	
func _set_label( _label: String ) -> void:
	label = _label
	self._update()

func _ready() -> void:
	#print( "Label: %s" % self.label )
	self.rich_text_label.text = self.label
	self.texture_button.texture_normal = self.texture_normal
	self.texture_button.texture_disabled = self.texture_disabled
	self.texture_button.texture_focused = self.texture_focused
	self.texture_button.name = "%sTextureButton" % [ self.label ]
	self._update()

func _update() -> void:
	if self.texture_button == null:
		return
	if self.rich_text_label == null:
		return
	self.rich_text_label.text = self.label
	match self.state:
		State.ENABLED:
			self.texture_button.disabled = false
			self.texture_button.focus_mode = FocusMode.FOCUS_ALL
			self.visible = true
		State.DISABLED:
			self.texture_button.disabled = true
			self.texture_button.focus_mode = FocusMode.FOCUS_NONE
			self.visible = true
		State.HIDDEN:
			self.visible = false
	
func _on_texture_button_pressed() -> void:
	self.pressed.emit()


func _on_focus_entered() -> void:
	self.texture_button.grab_focus.call_deferred()


func _on_texture_button_focus_entered() -> void:
	self.animation_player.play( "Focused", -1.0, 1.0/self.focus_duration, false )


func _on_texture_button_focus_exited() -> void:
	self.animation_player.play( "Focused", -1.0, -1.0/self.focus_duration, true )
