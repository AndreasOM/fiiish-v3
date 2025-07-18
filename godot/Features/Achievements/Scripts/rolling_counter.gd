class_name RollingCounter
extends Node

var _duration: float = 1.0
var _bucket_duration: float = 0.1

var _total: int = 0

var _current: int = 0
var _history: Array[ int ] = []
var _bucket_age: float = 0.0

func _init( duration: float, bucket_duration: float ) -> void:
	self._duration = duration
	self._bucket_duration = bucket_duration
	
	self.reset()

func reset() -> void:
	self._current = 0
	self._total = 0
	var bucket_count = self._duration / self._bucket_duration
	for _i in range( bucket_count ):
		self._history.push_back( 0 )
	
func _process( delta: float ) -> void:
	self._bucket_age += delta
	if self._bucket_age < self._bucket_duration:
		return
	self._bucket_age -= self._bucket_duration
	self._history.push_back( self._current )
	self._current = 0
	var outdated = self._history.pop_front()
	self._total -= outdated

func increment( amount: int ) -> void:
	self._current += amount
	self._total += amount
	
func get_total() -> int:
	return self._total
