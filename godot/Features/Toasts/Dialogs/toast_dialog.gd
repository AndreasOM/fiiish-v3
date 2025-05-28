@tool

class_name ToastDialog
extends Dialog

@export var max_toasts: int = 5
@export var push_speed: float = 12.0
@export var reward_test_icon: Texture = null
@export_tool_button("Clear Tween") var clear_tween_button = clear_tween.bind()
@export_tool_button("Clear Toasts") var clear_toats_button = clear_toasts.bind()
@export_tool_button("Add Toast") var add_toast_button = add_toast.bind( "Toast" )
@export_tool_button("Add Toast Simple Text") var add_simple_text_toast_button = add_simple_text_toast.bind( "Simple" )
@export_tool_button("Add Toast Achievement") var add_achievement_toast_button = add_achievement_toast.bind( "SingleRunDistance1" )
@export_tool_button("Add Toast Reward") var add_reward_toast_button = add_reward_toast.bind( 10, self.reward_test_icon, "" )

@onready var toast_container: VBoxContainer = %ToastContainer
@onready var margin_container: MarginContainer = %MarginContainer

var _queued_toasts: Array[ Control ] = [ ]
var _tween: Tween = null
const SIMPLE_TEXT_TOAST = preload("res://Features/Toasts/Dialogs/simple_text_toast.tscn")
const ACHIEVEMENT_TOAST = preload("res://Features/Toasts/Dialogs/achievement_toast.tscn")
const REWARD_TOAST = preload("res://Features/Toasts/Dialogs/reward_toast.tscn")

func _ready() -> void:
	self.margin_container.add_theme_constant_override("margin_top", 0)
	# self.add_toast( "Ready..." )
	
func clear_tween() -> void:
	if self._tween == null:
		return
	self._tween.stop()
	self._tween = null

func clear_toasts() -> void:
	self._queued_toasts.clear()
	for t in self.toast_container.get_children():
		t.queue_free()
	self.margin_container.add_theme_constant_override("margin_top", 0)
	print("Cleared toasts")
	
func add_reward_toast( amount: int, icon: Texture, extra: String ) -> RewardToast:
	var rt = REWARD_TOAST.instantiate()
	rt.amount = amount
	rt.icon = icon
	rt.extra = extra
	self._queued_toasts.push_back( rt )
	return rt
	
func add_achievement_toast( id: String ) -> AchievementToast:
	var at = ACHIEVEMENT_TOAST.instantiate()
	if self._dialog_manager == null:
		pass
	else:
		var gm = self._dialog_manager.game.get_game_manager()
		var acm = gm.get_achievement_config_manager()
		var ac = acm.get_config( id )
		at.config = ac
	self._queued_toasts.push_back( at )
	return at
	
func add_simple_text_toast( text: String ) -> SimpleTextToast:
	var stt = SIMPLE_TEXT_TOAST.instantiate()
	self._queued_toasts.push_back( stt )
	stt.text = text
	return stt
	
func add_toast( text: String ) -> void:
	var cr = ColorRect.new()
	cr.custom_minimum_size = Vector2( 640, 64 + randi_range( 0, 256 ) )
	cr.color = Color.HOT_PINK
	cr.color.r = randf_range(0.1, 0.9)
	cr.color.g = randf_range(0.1, 0.9)
	cr.color.b = randf_range(0.1, 0.9)
	self._queued_toasts.push_back( cr )
	print("Queued toast")
	
func _process( delta: float ) -> void:
	if !self._queued_toasts.is_empty():
		var tc = self.toast_container.get_child_count()
		if tc < self.max_toasts:
			var toast: Control = self._queued_toasts.pop_front()
			# toast.add_theme_color_override("modulate", Color.TRANSPARENT)
			toast.modulate = Color.TRANSPARENT
			var tween = create_tween()
			tween.tween_property(
				toast,
				"modulate",
				Color.WHITE,
				0.5
			)
			
			self.toast_container.add_child( toast )
			if self._tween == null || !self._tween.is_running():
				self.push_out_toast( toast )
	
func push_out_toast( toast: Control ) -> void:
	print("Creating tween for toast")
	var toast_height = toast.size.y
	print("Toast height %d" % toast_height )
	var push_duration = toast_height / self.push_speed
	var wait_duration = 1.0
	self._tween = create_tween()
	self._tween.tween_property(
		self.margin_container,
		"theme_override_constants/margin_top",
		0.0,
		wait_duration
	)
	self._tween.tween_property(
		self.margin_container,
		"theme_override_constants/margin_top",
		-toast_height,
		push_duration
	)
	self._tween.tween_callback( toast_pushed_out.bind( toast ) )
	
func toast_pushed_out( toast: Control ) -> void:
	if self.toast_container.get_children().has( toast ):
		self.toast_container.remove_child( toast )
		toast.queue_free()
	self.margin_container.add_theme_constant_override("margin_top", 0)
	if self.toast_container.get_child_count() > 0:
		var next_toast = self.toast_container.get_child(0)
		self.push_out_toast( next_toast )
		
func close( duration: float):
	fade_out( duration )

func open( duration: float):
	Events.global_message.connect( _on_global_message )
	Events.achievement_completed.connect( _on_achievement_completed )
	Events.reward_received.connect( _on_reward_received )
	fade_in( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )

func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()

func _on_global_message( text: String ) -> void:
	self.add_simple_text_toast( text )
	
func _on_achievement_completed( id: String ) -> void:
	self.add_achievement_toast( id )

func _on_reward_received( amount: int, icon: Texture, extra: String ) -> void:
	self.add_reward_toast( amount, icon, extra )
