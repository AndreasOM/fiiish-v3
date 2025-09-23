extends TextureButton
class_name SkillUpgradeItemButton

@export var enabledTexture: Texture;
@export var unlockableTexture: Texture;
@export var unlockableFocusedTexture: Texture;
@export var disabledTexture: Texture;
@export var demoDisabledTexture: Texture;
@export var demoDisabledFocusedTexture: Texture;
@export var state: State = State.Disabled;

signal on_pressed

var _id: int = -1;

enum State
{
	Enabled,
	Unlockable,
	Disabled,
	DemoDisabled,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match state:
		State.Enabled:
			texture_normal = enabledTexture
			self.texture_focused = null
		State.Unlockable:
			texture_normal = unlockableTexture
			self.texture_focused = self.unlockableFocusedTexture
		State.Disabled:
			texture_normal = disabledTexture
			self.texture_focused = null
		State.DemoDisabled:
			texture_normal = demoDisabledTexture
			self.texture_focused = self.demoDisabledFocusedTexture

	self.focus_neighbor_left = NodePath(".")
	self.focus_neighbor_right = NodePath(".")

func set_next_control( n: Control ) -> void:
	var path = NodePath(".")
	if n != null:
		path = self.get_path_to( n )
		
	self.focus_neighbor_bottom = path
	self.focus_next = path

func set_prev_control( p: Control ) -> void:
	var path = NodePath(".")
	if p != null:
		path = self.get_path_to( p )
		
	self.focus_neighbor_top = path
	self.focus_previous = path
	
func set_id( id: int ) -> void:
	_id = id

func set_state_enabled() -> void:
	state = State.Enabled
	texture_normal = enabledTexture
	self.focus_mode = Control.FOCUS_NONE

func set_state_unlockable() -> void:
	state = State.Unlockable
	texture_normal = unlockableTexture
	self.texture_focused = self.unlockableFocusedTexture
	self.focus_mode = Control.FOCUS_ALL

func set_state_disabled() -> void:
	state = State.Disabled
	texture_normal = disabledTexture
	self.focus_mode = Control.FOCUS_NONE
	
	
func set_state_demo_disabled() -> void:
	state = State.DemoDisabled
	texture_normal = demoDisabledTexture
	self.texture_focused = self.demoDisabledFocusedTexture
	self.focus_mode = Control.FOCUS_ALL
	

func _on_pressed() -> void:
	match state:
		State.Unlockable:
			on_pressed.emit( _id )
		State.DemoDisabled:
			on_pressed.emit( _id )
		_:
			# just ignore
			pass
