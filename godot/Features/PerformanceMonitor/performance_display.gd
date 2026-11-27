extends Node2D


func _process(_delta) -> void:
	queue_redraw()
	
func _draw() -> void:
	PerformanceMonitor.draw( self )
