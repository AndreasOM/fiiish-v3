@tool

extends MarginContainer
class_name LeaderBoardElement

@export var was_new_best: bool = false : set = set_was_new_best
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D

func set_was_new_best( b: bool ) -> void:
	was_new_best = b
	_update_particles()

func _ready() -> void:
	if !Engine.is_editor_hint():
		# in editor keep for testing
		self._clear_existing_entries()
	_update_particles()

func _update_particles() -> void:
	if gpu_particles_2d != null:
		gpu_particles_2d.emitting = was_new_best
		
func _clear_existing_entries() -> void:
	for c in %Entries.get_children():
		%Entries.remove_child(c)
	
func set_leaderboard( leaderboard: Leaderboard, score_formatter: Callable = Callable() ) -> void:
	self._clear_existing_entries()

	var ee = preload("res://Dialogs/Leaderboard/leaderboard_element_entry.tscn")

	var es = leaderboard.entries()
	var latest = leaderboard.last_added_entry_position()
	for i in range(0, es.size()):
		var e = es.get_entry( i )
		var ei = ee.instantiate()
		ei.rank = "%d." % ( i + 1 )
		ei.participant = e.participant()
		if score_formatter.is_null():
			ei.score = "%d" % e.score()
		else:
			ei.score = score_formatter.call( e.score() )
			
		ei.was_latest = latest == i
			
		%Entries.add_child(ei)
		
		self.set_was_new_best( latest == 0 )
