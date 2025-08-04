class_name AchievementElementView
extends MarginContainer

signal collect_pressed( id: String )

@export var config: AchievementConfig = null : set = set_achievement_config
@export var state: AchievementStates.State = AchievementStates.State.UNKNOWN : set = set_state
@onready var icon: TextureRect = %Icon
@onready var name_label: RichTextLabel = %NameLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var extra_rewards_label: RichTextLabel = %ExtraRewardsLabel
@onready var collect_texture_button: TextureButton = %CollectTextureButton
@onready var skill_achievment_reward_element: AchievementRewardElement = %SkillAchievmentRewardElement
@onready var coin_achievment_reward_element: AchievementRewardElement = %CoinAchievmentRewardElement

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
	self.description_label.text = self.config.description
	
	self.skill_achievment_reward_element.value = self.config.reward_skill_points
	self.coin_achievment_reward_element.value = self.config.reward_coins
	
	var extra_rewards_text = ""
	var sep = ""
	for ew in self.config.reward_extra:
		extra_rewards_text += "%s%s" % [ sep, ew ]
		sep = "\n--\n"
	
	self.extra_rewards_label.text = extra_rewards_text
	
	match self.state:
		AchievementStates.State.UNKNOWN:
			#self.collect_texture_button.visible = false
			self.collect_texture_button.modulate = Color.TRANSPARENT
			self.icon.modulate = Color.DIM_GRAY
		AchievementStates.State.COMPLETED:
			#self.collect_texture_button.visible = true
			self.collect_texture_button.modulate = Color.WHITE
			self.icon.modulate = Color.WHITE
		AchievementStates.State.COLLECTED:
			#self.collect_texture_button.visible = false
			self.collect_texture_button.modulate = Color.TRANSPARENT
			self.icon.modulate = Color.WHITE
		_:
			#self.collect_texture_button.visible = false
			self.collect_texture_button.modulate = Color.TRANSPARENT
			self.icon.modulate = Color.WHITE


func _on_collect_texture_button_pressed() -> void:
	if self.state != AchievementStates.State.COMPLETED:
		return
	if self.config == null:
		return
		
	self.collect_pressed.emit( self.config.id )
