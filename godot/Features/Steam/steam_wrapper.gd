extends Node


#const NON_STEAM_OS: Array[ String ] = ["iOS","Android","Web","macOS"]
const NON_STEAM_OS: Array[ String ] = ["iOS","Android","Web"]
const SteamWrapperInner = "res://Features/Steam/steam_wrapper_inner.gd"

var _inner: Variant = null

var _developer_ids: Dictionary[ int, bool ] = {
	
}

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

func add_developer_id( id: int ) -> void:
	self._developer_ids[ id ] = true
	
func is_developer() -> bool:
	if OS.has_feature("editor_runtime"):
		return true
	
	var steam_id = SteamWrapper.getSteamID()
	return self._developer_ids.get( steam_id, false )
	
func getSteamID() -> int:
	if self._inner == null:
		return 0

	var steam = self._inner.get_steam()
	if steam == null:
		return 0

	if !steam.isSteamRunning():
		return 0

	return steam.getSteamID()

func isSteamRunning() -> bool:
	if self._inner == null:
		return false

	var steam = self._inner.get_steam()
	if steam == null:
		return false

	return steam.isSteamRunning()

func setAchievement(id: String) -> bool:
	if self._inner == null:
		return false

	var steam = self._inner.get_steam()
	if steam == null:
		return false

	if !steam.isSteamRunning():
		return false

	return steam.setAchievement(id)

func storeStats() -> bool:
	if self._inner == null:
		return false

	var steam = self._inner.get_steam()
	if steam == null:
		return false

	if !steam.isSteamRunning():
		return false

	return steam.storeStats()

func getAchievement(id: String) -> Dictionary:
	if self._inner == null:
		return {"ret": false, "achieved": false}

	var steam = self._inner.get_steam()
	if steam == null:
		return {"ret": false, "achieved": false}

	if !steam.isSteamRunning():
		return {"ret": false, "achieved": false}

	return steam.getAchievement(id)

func clearAchievement(id: String) -> bool:
	if self._inner == null:
		return false

	var steam = self._inner.get_steam()
	if steam == null:
		return false

	if !steam.isSteamRunning():
		return false

	return steam.clearAchievement(id)

func getFriendPersonaName(steam_id: int) -> String:
	if self._inner == null:
		return ""

	var steam = self._inner.get_steam()
	if steam == null:
		return ""

	if !steam.isSteamRunning():
		return ""

	return steam.getFriendPersonaName(steam_id)

func getLeaderboardName(handle: int) -> String:
	if self._inner == null:
		return ""

	var steam = self._inner.get_steam()
	if steam == null:
		return ""

	if !steam.isSteamRunning():
		return ""

	return steam.getLeaderboardName(handle)

func get_steam_init_result() -> Dictionary:
	if self._inner == null:
		return {"status": 2, "verbal": "Steam client not available"}

	var steam = self._inner.get_steam()
	if steam == null:
		return {"status": 2, "verbal": "Steam client not available"}

	return steam.get_steam_init_result()

# Called every frame - hot path
func runFrame() -> void:
	if self._inner == null:
		return

	var steam = self._inner.get_steam()
	if steam == null:
		return

	if !steam.isSteamRunning():
		return

	steam.runFrame()

# Called every frame per action - hot path
func getDigitalActionData(input_device: int, action_handle: int) -> Dictionary:
	if self._inner == null:
		return {"active": false, "state": false}

	var steam = self._inner.get_steam()
	if steam == null:
		return {"active": false, "state": false}

	if !steam.isSteamRunning():
		return {"active": false, "state": false}

	return steam.getDigitalActionData(input_device, action_handle)

func getDigitalActionHandle(action_name: String) -> int:
	if self._inner == null:
		return 0

	var steam = self._inner.get_steam()
	if steam == null:
		return 0

	if !steam.isSteamRunning():
		return 0

	return steam.getDigitalActionHandle(action_name)

func getActionSetHandle(action_set_name: String) -> int:
	if self._inner == null:
		return 0

	var steam = self._inner.get_steam()
	if steam == null:
		return 0

	if !steam.isSteamRunning():
		return 0

	return steam.getActionSetHandle(action_set_name)

func activateActionSet(input_device: int, action_set_handle: int) -> void:
	if self._inner == null:
		return

	var steam = self._inner.get_steam()
	if steam == null:
		return

	if !steam.isSteamRunning():
		return

	steam.activateActionSet(input_device, action_set_handle)
