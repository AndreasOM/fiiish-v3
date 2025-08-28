extends Node


#const NON_STEAM_OS: Array[ String ] = ["iOS","Android","Web","macOS"]
const NON_STEAM_OS: Array[ String ] = ["iOS","Android","Web"]
const SteamWrapperInner = "res://Features/Steam/steam_wrapper_inner.gd"

var _inner: Variant = null

func _ready() -> void:
	var os = OS.get_name()
	if self.NON_STEAM_OS.has( os ):
		return
		
	var s = load(SteamWrapperInner)
	var n = Node.new()
	n.set_script(s)
	
	self.add_child( n )
	self._inner = n
	
func is_available() -> bool:
	return self._inner != null
	
func get_initial_response() -> Dictionary:
	if self._inner == null:
		return {}
	
	if !self._inner.has_method("get_initial_response"):
		return {}
		
	return self._inner.get_initial_response()

func get_steam() -> Variant:
#	var os = OS.get_name()
#	if self.NON_STEAM_OS.has( os ):
#		return null
		
	if self._inner == null:
		return null
	
	if !self._inner.has_method("get_steam"):
		return null
		
	return self._inner.get_steam()
