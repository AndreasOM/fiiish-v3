extends Node

var _steam_input_handles: Dictionary = {}
var _digital_action_handles: Dictionary[ String, int ] = {}

const DIGITIAL_ACTIONS: Dictionary[ String, String ] = {
	"dive": "swim_down"
}

var _pressed_digital_actions: Dictionary[ String, bool ] = {}

func _ready() -> void:
	return
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		steam.input_device_connected.connect( _on_input_device_connected )
		steam.input_device_disconnected.connect( _on_input_device_disconnected )
		
	
func _process(delta: float) -> void:
	return
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		steam.runFrame()
		for da in self.DIGITIAL_ACTIONS.keys():
			var action_handle = self._digital_action_handles.get( da, -1 )
			if action_handle == -1:
				continue
			var target = self.DIGITIAL_ACTIONS.get( da, "" )
			if target == "":
				continue
				
			for input_device in self._steam_input_handles.keys():
				if !self._steam_input_handles.get( input_device, false ):
					continue
				var data = steam.getDigitalActionData( input_device, action_handle )
				if !data.get("active", false):
					continue
				
				var pressed = data.get("state", false)
				var was_pressed = self._pressed_digital_actions.get(da, false)
				
				if pressed == was_pressed:
					continue

				var ev = InputEventAction.new()
				ev.action = target
					
				if pressed:
					self._pressed_digital_actions[ da ] = true
					ev.pressed = true
					Events.broadcast_global_message("Pressed %s" % da)
				else:
					self._pressed_digital_actions[ da ] = false
					ev.pressed = false
					Events.broadcast_global_message("Released %s" % da)

				Input.parse_input_event(ev)
				

func _on_input_device_connected( input_handle: int ) -> void:
	self._steam_input_handles[ input_handle ] = true
	if self._digital_action_handles.size() != self.DIGITIAL_ACTIONS.size():
		self._digital_action_handles.clear()
		if SteamWrapper.is_available():
			var steam = SteamWrapper.get_steam()
			for da in self.DIGITIAL_ACTIONS.keys():
				var h = steam.getDigitalActionHandle( da )
				self._digital_action_handles[ da ] = h
				Events.broadcast_global_message( "Action %s -> %d" % [ da, h ] )
		

func _on_input_device_disconnected( input_handle: int ) -> void:
	self._steam_input_handles[ input_handle ] = false

	
