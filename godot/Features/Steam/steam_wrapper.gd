extends Node


#const NON_STEAM_OS: Array[ String ] = ["iOS","Android","Web","macOS"]
const NON_STEAM_OS: Array[ String ] = ["iOS","Android","Web"]
const SteamWrapperInner = "res://Features/Steam/steam_wrapper_inner.gd"

var _inner: Variant = null

func _ready() -> void:
	print_rich("[color=yellow]SteamWrapper - _ready ->[/color]")
	var os = OS.get_name()
	if self.NON_STEAM_OS.has( os ):
		return
		
	var s = load(SteamWrapperInner)
	var n = Node.new()
	n.set_script(s)
	
	self.add_child( n )
	self._inner = n
	print_rich("[color=yellow]<- SteamWrapper - _ready[/color]")
	
func is_available() -> bool:
#	return false
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

func get_steam_controller_input() -> Variant:
#	var os = OS.get_name()
#	if self.NON_STEAM_OS.has( os ):
#		return null

	if self._inner == null:
		return null

	if !self._inner.has_method("get_steam_controller_input"):
		return null

	return self._inner.get_steam_controller_input()

func getSteamID() -> int:
	if self._inner == null:
		return 0

	var steam = self._inner.get_steam()
	if steam == null:
		return 0

	if !steam.isSteamRunning():
		return 0

	return steam.getSteamID()
