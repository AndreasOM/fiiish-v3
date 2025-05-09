extends Node2D

#var _orig_pos: Vector2 = Vector2( 0.0, 0.0 )
#var _is_shaking: bool = false

#func _ready():
#	self._orig_pos = self.position
	
#func _process(delta: float) -> void:
#	if Input.is_key_pressed(KEY_S):
#		self.trigger()

func trigger():
	#var duration = 0.125
	#var distance = 5
	#if self._is_shaking:
	#	return
	#self._is_shaking = true
	if %AnimationPlayer.is_playing():
		return
	%AnimationPlayer.play("Shake")
	
	
#	var p0 = self.position
#	var p1 = p0 + Vector2( distance, 0.0 )
#	var p2 = p0 + Vector2( -distance, 0.0 )
#	var tween = get_tree().create_tween()
#	# tween.set_ease(Tween.EASE_IN_OUT)
#	tween.set_ease(Tween.EASE_IN)
#	# tween.set_trans(Tween.TRANS_BACK)
#	tween.set_trans(Tween.TRANS_CUBIC)
#	tween.tween_property(self, "position", p1, 0.25*duration)
#	tween.tween_property(self, "position", p2, 0.5*duration)
#	tween.tween_property(self, "position", p0, 0.25*duration)
#	tween.tween_callback( tween_done )
	
#func tween_done():
#	self._is_shaking = false
