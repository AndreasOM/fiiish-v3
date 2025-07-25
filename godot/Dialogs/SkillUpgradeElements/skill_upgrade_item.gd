extends VBoxContainer
class_name SkillUpgradeItem

@export var title: String;
@export var current: int = 0;
@export var unlockable: int = 0;
@export var maximum: int = 0;
@export var unlock_price: int = 0 : set = set_unlock_price

@export var skill_id: SkillIds.Id = SkillIds.Id.NONE;

signal skill_buy_triggered;

var button = preload("res://Dialogs/SkillUpgradeElements/skill_upgrade_item_button.tscn")

@onready var skill_name_label: Label = %SkillNameLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var scroll_container_hbox_container: HBoxContainer = %ScrollContainer/HBoxContainer
@onready var cost_label: Label = %CostLabel
@onready var skill_point_icon: TextureRect = %SkillPointIcon

func _ready() -> void:
	self.skill_name_label.text = title;
	_create_buttons()

func _create_buttons() -> void:
	var p = self.scroll_container_hbox_container
	for o in p.get_children():
		var suib = o as SkillUpgradeItemButton
		if suib != null:
			p.remove_child( suib )
			suib.queue_free()

	for i in range(0,maximum):
		var b = button.instantiate()
		b.set_id( i+1 )
		b.connect("on_pressed", _on_button_pressed)
		p.add_child(b)

func _on_button_pressed( i: int ) -> void:
	print( "pressed %d" % i)
	skill_buy_triggered.emit( skill_id, i )
	# :HACK:
	# set_current( i )
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
#	var tx = 0 + max( 0, current-1 ) * 64 + 32 + 32
	var tx = 0 + current * 64 + 32 + 32
	
	self.scroll_container.scroll_horizontal = lerp( self.scroll_container.scroll_horizontal, tx, 0.08 )

func _update_states() -> void:
	var p = self.scroll_container_hbox_container
	var i = 0
	for o in p.get_children():
		var suib = o as SkillUpgradeItemButton
		if suib != null:
			if i < current:
				suib.set_state_enabled()
			elif i < unlockable:
				suib.set_state_unlockable()
			else:
				suib.set_state_disabled()
				
			i += 1
	
func set_unlockable( v: int ) -> void:
	unlockable = v
	_update_states()
	
func set_current( v: int) -> void:
	current = v
	_update_states()

func setMaximum( v: int) -> void:
	maximum = v
	_update_states()

func set_unlock_price( p: int ) -> void:
	unlock_price = p
	if unlock_price < 0:
		self.cost_label.text = ""
		self.cost_label.visible = false
		self.skill_point_icon.visible = false
	else:
		self.cost_label.text = "%d" % self.unlock_price
		self.cost_label.visible = true
		self.skill_point_icon.visible = true

	
func prepare_fade_in() -> void:
	self.scroll_container.scroll_horizontal = 0
