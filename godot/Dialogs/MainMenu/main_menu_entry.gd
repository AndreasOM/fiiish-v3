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

func _set_state( s: State ) -> void:
	state = s
	self._update()
	
func _set_label( _label: String ) -> void:
	label = _label
	%RichTextLabel.text = self.label
	
func _ready() -> void:
	#print( "Label: %s" % self.label )
	%RichTextLabel.text = self.label
	%TextureButton.texture_normal = self.texture_normal
	%TextureButton.texture_disabled = self.texture_disabled
	%TextureButton.texture_focused = self.texture_focused
	self._update()

func _update() -> void:
	match self.state:
		State.ENABLED:
			%TextureButton.disabled = false
			%TextureButton.focus_mode = FocusMode.FOCUS_ALL
		State.DISABLED:
			%TextureButton.disabled = true
			%TextureButton.focus_mode = FocusMode.FOCUS_NONE
		State.HIDDEN:
			self.visible = false
	
func _on_texture_button_pressed() -> void:
	self.pressed.emit()


func _on_focus_entered() -> void:
	%TextureButton.grab_focus.call_deferred()


func _on_texture_button_focus_entered() -> void:
	self.animation_player.play( "Focused", -1.0, 1.0/self.focus_duration, false )


func _on_texture_button_focus_exited() -> void:
	self.animation_player.play( "Focused", -1.0, -1.0/self.focus_duration, true )
