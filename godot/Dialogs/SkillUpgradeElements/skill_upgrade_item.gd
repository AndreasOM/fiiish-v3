extends VBoxContainer
class_name SkillUpgradeItem

@export var title: String;
@export var current: int = 0;
@export var unlockable: int = 0;
@export var maximum: int = 0;

@export var skill_id: SkillIds.Id = SkillIds.Id.NONE;

signal skill_buy_triggered;

var button = preload("res://Dialogs/SkillUpgradeElements/skill_upgrade_item_button.tscn")

@onready var skill_name_label: Label = %SkillNameLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var scroll_container_hbox_container: HBoxContainer = %ScrollContainer/HBoxContainer

func _ready() -> void:
	self.skill_name_label.text = title;
	_createButtons()

func _createButtons():
	var p = self.scroll_container_hbox_container
	for o in p.get_children():
		var suib = o as SkillUpgradeItemButton
		if suib != null:
			p.remove_child( suib )
			suib.queue_free()

	for i in range(0,maximum):
		var b = button.instantiate()
		b.setId( i+1 )
		b.connect("on_pressed", _on_button_pressed)
		p.add_child(b)

func _on_button_pressed( i: int ):
	print( "pressed %d" % i)
	skill_buy_triggered.emit( skill_id, i )
	# :HACK:
	# setCurrent( i )
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
#	var tx = 0 + max( 0, current-1 ) * 64 + 32 + 32
	var tx = 0 + current * 64 + 32 + 32
	
	self.scroll_container.scroll_horizontal = lerp( self.scroll_container.scroll_horizontal, tx, 0.08 )

func _updateStates():
	var p = self.scroll_container_hbox_container
	var i = 0
	for o in p.get_children():
		var suib = o as SkillUpgradeItemButton
		if suib != null:
			if i < current:
				suib.setEnabled()
			elif i < unlockable:
				suib.setUnlockable()
			else:
				suib.setDisabled()
				
			i += 1
	
func setUnlockable( v: int ):
	unlockable = v
	_updateStates()
	
func setCurrent( v: int):
	current = v
	_updateStates()

func setMaximum( v: int):
	maximum = v
	_updateStates()

func prepare_fade_in():
	self.scroll_container.scroll_horizontal = 0
