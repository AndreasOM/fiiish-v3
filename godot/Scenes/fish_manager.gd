class_name FishManager
extends Node

signal last_fish_killed
signal all_fish_dead
signal all_fish_waiting_for_start

@onready var fishes: Node2D = %Fishes

func _ready() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.state_changed.connect( _on_fish_state_changed )
		f.request_respawn.connect( _on_fish_request_respawn )

	Events.zone_edit_enabled.connect( _on_zone_edit_enabled )
	Events.zone_edit_disabled.connect( _on_zone_edit_disabled )

func _on_fish_state_changed( state: Fish.State ) -> void:
	print("Fish State changed to %d" % state)
	match state:
		Fish.State.WAITING_FOR_START:
			if self.are_all_fish_waiting_for_start():
				self.all_fish_waiting_for_start.emit()
		Fish.State.KILLED:
			if !self.is_any_fish_alive():
				self.last_fish_killed.emit()
		Fish.State.DEAD:
			if self.are_all_fish_dead():
				self.all_fish_dead.emit()
		_:
			pass

func _on_fish_request_respawn( fish: Fish ) -> void:
#	fish._goto_respawning()
	pass
	
func is_any_fish_alive() -> bool:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		if f.is_alive():
			return true
			
	return false

func are_all_fish_dead() -> bool:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		if !f.is_dead():
			return false
			
	return true

func are_all_fish_waiting_for_start() -> bool:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		if !f.state == Fish.State.WAITING_FOR_START:
			return false
			
	return true
	
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

func kill_all_fishes() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f._goto_killed()

func move_fish( v: Vector2 ) -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f.move( v )

func respawn_fishes() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f._goto_respawning()

func start_swimming() -> void:
	for c in self.fishes.get_children():
		var f = c as Fish
		if f == null:
			continue
		f._goto_swimming()

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
