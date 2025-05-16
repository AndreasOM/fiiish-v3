class_name FishManager
extends Node

@onready var fishes: Node2D = %Fishes

func _ready() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.state_changed.connect( _on_fish_state_changed )

	Events.zone_edit_enabled.connect( _on_zone_edit_enabled )
	Events.zone_edit_disabled.connect( _on_zone_edit_disabled )

func _on_fish_state_changed( state: Fish.State ) -> void:
	pass

func set_skill_effect_set( ses: SkillEffectSet ) -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.set_skill_effect_set( ses )

func set_invincible( invicible: bool ):
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.set_invincible( invicible )

func goto_dying_without_result() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f._goto_dying_without_result()

func move_fish( v: Vector2 ) -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.move( v )

func _on_zone_edit_enabled() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.goto_edit_mode()

func _on_zone_edit_disabled() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.goto_play_mode()
