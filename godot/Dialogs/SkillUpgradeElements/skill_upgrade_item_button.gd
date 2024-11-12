extends TextureButton
class_name SkillUpgradeItemButton

@export var enabledTexture: Texture;
@export var unlockableTexture: Texture;
@export var disabledTexture: Texture;
@export var state: State = State.Disabled;

signal on_pressed;

var _id: int = -1;

enum State
{
	Enabled,
	Unlockable,
	Disabled,
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


func setId( id: int ):
	_id = id

func setEnabled():
	state = State.Enabled
	texture_normal = enabledTexture

func setUnlockable():
	state = State.Unlockable
	texture_normal = unlockableTexture

func setDisabled():
	state = State.Disabled
	texture_normal = disabledTexture
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	match state:
		State.Unlockable:
			on_pressed.emit( _id )
		_:
			# just ignore
			pass
