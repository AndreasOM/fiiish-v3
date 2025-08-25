# class_name PerfomanceMonitor
extends Node2D

var _areas: Dictionary[ String, int ] = {}
var _path: Array[String] = []

func draw( ci: CanvasItem ) -> void:
	var x = 0
	var w = 20.0
	var y = 500
	var s = 2.0
	for a in self._areas:
		var d = self._areas[ a ]
		# print( "%s -> %d" %[ a, d ])
		ci.draw_line( Vector2( x, y ), Vector2(x,y-d*s), Color.WHITE, w )
		x = x + w
	pass

func next_frame() -> void:
	# print( _areas )
	# self._areas.clear()
	for a in self._areas:
		self._areas[a] = 0
	pass
	
func enter_performance_area( name: String ) -> void:
	self._path.push_back( name )
	pass

func leave_performance_area( name: String, duration: int ) -> void:
	var full_name = "/".join( self._path )
	var n = self._path.pop_back()
	var pa = self._areas.get_or_add( full_name, 0 )
	self._areas[ full_name ] = pa + duration
