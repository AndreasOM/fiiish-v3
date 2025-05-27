class_name AchievementElementView
extends MarginContainer


@export var config: AchievementConfig = null : set = set_achievement_config
@export var state: AchievementStates.State = AchievementStates.State.UNKNOWN : set = set_state
@onready var icon: TextureRect = %Icon
@onready var name_label: RichTextLabel = %NameLabel

func _ready() -> void:
	self._update()

func set_achievement_config( c: AchievementConfig ) -> void:
	config = c
	self._update()

func set_state( s: AchievementStates.State ) -> void:
	state = s
	self._update()


func _update() -> void:
	if self.config == null:
		return
		
	if self.icon == null:
		return

	if self.name_label == null:
		return

	#self.name = "AchievementElementView-%s" % self.config.id
	self.icon.texture = self.config.icon
	self.name_label.text = self.config.name
	
	match self.state:
		AchievementStates.State.UNKNOWN:
			self.icon.modulate = Color.DIM_GRAY
		_:
			self.icon.modulate = Color.WHITE
