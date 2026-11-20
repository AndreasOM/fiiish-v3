class_name PerformanceArea

var _name: String = ""
var _start_time: int = 0
var _is_tracked: bool = false

func _init( name: String ):
	self._name = name
	self._is_tracked = PerformanceMonitor.enabled
	if !self._is_tracked:
		return
	# print("PA - Start - %s" % self._name )
	self._start_time = Time.get_ticks_usec()
	PerformanceMonitor.enter_performance_area( self._name )
	

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if !self._is_tracked:
			return
		var end_time = Time.get_ticks_usec()
		var duration = end_time - self._start_time
		# print("PA - End - %s took %d usecs" % [ self._name, duration ] )
		PerformanceMonitor.leave_performance_area( self._name, duration )
