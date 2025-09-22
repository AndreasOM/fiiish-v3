extends Node

var _steam_input_handles: Dictionary = {}
var _digital_action_handles: Dictionary[ String, int ] = {}

const DIGITIAL_ACTIONS: Dictionary[ String, String ] = {
	"Swim_Dive":			"Swim_Dive",
	"Swim_OpenMainMenu":	"Swim_OpenMainMenu",
	"Swim_TogglePause":		"Global_TogglePause",
	
	"Menu_GotoSwim":		"Menu_GotoSwim",
	"Menu_CloseMainMenu":	"MainMenu_CloseMainMenu",
	"Menu_TogglePause":		"Global_TogglePause",
	"Menu_Confirm":			"Menu_Confirm",
	"Menu_Cancel":			"Menu_Cancel",
	"Menu_Up":				"Menu_Up",
	"Menu_Down":			"Menu_Down",
	"Menu_Left":			"Menu_Left",
	"Menu_Right":			"Menu_Right",
	"Menu_Next":			"Menu_Next",
	"Menu_Prev":			"Menu_Prev",
}

var _pressed_digital_actions: Dictionary[ String, bool ] = {}

func _ready() -> void:
	print_rich("[color=yellow]SteamInput - _ready ->[/color]")
	
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		steam.input_device_connected.connect( _on_input_device_connected )
		steam.input_device_disconnected.connect( _on_input_device_disconnected )
		
	print_rich("[color=yellow]<- SteamInput - _ready[/color]")

func _process(delta: float) -> void:
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

				# print_rich("[color=blue]Steam Input: %s -> %d[/color]" % [ da, int(pressed) ])
				var ev = InputEventAction.new()
				ev.action = target
					
				if pressed:
					self._pressed_digital_actions[ da ] = true
					ev.pressed = true
					# Events.broadcast_global_message("Pressed %s" % da)
				else:
					self._pressed_digital_actions[ da ] = false
					ev.pressed = false
					# Events.broadcast_global_message("Released %s" % da)

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
				if h == 0:
					Events.broadcast_global_message( "No mapping for %s -> %d" % [ da, h ] )
					print_rich( "[color=red]No mapping for %s -> %d[/color]" % [ da, h ] )
		

func _on_input_device_disconnected( input_handle: int ) -> void:
	self._steam_input_handles[ input_handle ] = false

	
