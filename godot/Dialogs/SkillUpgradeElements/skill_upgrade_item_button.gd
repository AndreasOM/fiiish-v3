extends TextureButton
class_name SkillUpgradeItemButton

@export var enabledTexture: Texture;
@export var unlockableTexture: Texture;
@export var disabledTexture: Texture;
@export var demoDisabledTexture: Texture;
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
		State.Unlockable:
			texture_normal = unlockableTexture
		State.Disabled:
			texture_normal = disabledTexture
		State.Disabled:
			texture_normal = demoDisabledTexture

func set_id( id: int ) -> void:
	_id = id

func set_state_enabled() -> void:
	state = State.Enabled
	texture_normal = enabledTexture

func set_state_unlockable() -> void:
	state = State.Unlockable
	texture_normal = unlockableTexture

func set_state_disabled() -> void:
	state = State.Disabled
	texture_normal = disabledTexture
	
func set_state_demo_disabled() -> void:
	state = State.DemoDisabled
	texture_normal = demoDisabledTexture
	

func _on_pressed() -> void:
	match state:
		State.Unlockable:
			on_pressed.emit( _id )
		State.DemoDisabled:
			on_pressed.emit( _id )
		_:
			# just ignore
			pass
