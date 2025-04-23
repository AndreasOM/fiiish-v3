extends Dialog

@export var game: Game = null
@export var max_history: int = 10
@export var max_command_history: int = 20

var _block_input: bool = false

var _history: Array = []
var _command_history: Array = [ ]
var _command_history_current = 0

var _commands: Array = [ DeveloperCommand ]

func close( duration: float):
	fade_out( duration )

func open( duration: float):
	fade_in( duration )
		
func fade_out( duration: float ):
	%FadeableContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeableContainer.fade_in( duration )

func set_game( game: Game ):
	self.game = game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.clear()
	self._commands.push_back( DeveloperCommandResume.new() )
	self._commands.push_back( DeveloperCommandFail.new() )
	self._commands.push_back( DeveloperCommandSucceed.new() )
	self._commands.push_back( DeveloperCommandGiveCoins1000.new() )
	self._commands.push_back( DeveloperCommandResetPlayer.new() )
	self._commands.push_back( DeveloperCommandResetLocalLeaderboards.new() )
	self._commands.push_back( DeveloperCommandCheatToggleInvincible.new() )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_developer_console"):
		print("Tilde")
		%FadeableContainer.toggle_fade( 0.1 )

func _input(event):
	if _block_input: # You can also check which actions using is_action.
		### %LineEdit._input(event)
		if event.is_action("toggle_developer_console"):
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("cursor_up"):
			get_viewport().set_input_as_handled()
			self.dec_command_history_current()
			var l = self.get_command_history_current()
			if l != null:
				%LineEdit.text = l
		elif event.is_action_pressed("cursor_down"):
			get_viewport().set_input_as_handled()
			self.inc_command_history_current()
			var l = self.get_command_history_current()
			if l != null:
				%LineEdit.text = l
			else:
				%LineEdit.text = ""
		elif event.is_action_pressed( "tab" ):
			var l = self.auto_complete( %LineEdit.text )
			if l != null:
				%LineEdit.text = l
				%LineEdit.set_caret_column( l.length() )
		
func clear():
	%RichTextLabel.clear()
	self._history.clear()
	self.update_history()
	pass

func auto_complete( l: String ):
	var candidates = []
	for c in self._commands:
		var cmd = c as DeveloperCommand
		if cmd == null:
			continue
		var s = cmd.syntax() as String
		if s != null:
			if s.begins_with( l ):
				candidates.push_back( s )
	
	# :HACK:
	if "help".begins_with( l ):
		candidates.push_back( "help" )
	if "clear".begins_with( l ):
		candidates.push_back( "clear" )
	
	match candidates.size():
		0:
			# self.add_history( "TAB: >%s<" % l )
			return null
		1:
			return candidates[ 0 ]
		_:
			for c in candidates:
				self.add_history( c )
				
			var c0 = candidates[ 0 ]
			var longest_prefix = l.length()	

			var sug = c0.left( longest_prefix )
			
			var done = false
			while true:
				longest_prefix+=1
				var next_sug = c0.left( longest_prefix )
				for c in candidates:
					if !c.begins_with( next_sug ):
						done = true
						break
				if done:
					break
				sug = next_sug
					
			return sug

func update_history():
	var h = "\n".join( self._history)
	%RichTextLabel.text = h
	
func add_history( line: String ):
	self._history.push_back( line )
	
	while self._history.size() > self.max_history:
		self._history.pop_front()
		
	self.update_history()

func add_command_history( line: String ):
	if self._command_history.size() > 0:
		# skip duplicates
		var prev = self._command_history.back()
		if prev == line:
			return

	self._command_history.push_back( line )
	
	while self._command_history.size() > self.max_command_history:
		self._command_history.pop_front()
		
func get_command_history_current():
	var c = self._command_history_current
	if c == 0:
		return null

	var l = self._command_history.size()
	# print("DEVELOPER_CONSOLE: current %d of %d" % [ c, l ] )
	if -c > l:
		return null
	
	var i = l + c
	return self._command_history[ i ]
	
func dec_command_history_current():
	var o = self._command_history_current
	var l = self._command_history.size()
	if -o < l:
		self._command_history_current -= 1
	# print("DEVELOPER_CONSOLE: %d -- => %d" % [ o, self._command_history_current ] )
	
func inc_command_history_current():
	var o = self._command_history_current
	if o < 0:
		self._command_history_current += 1
	# print("DEVELOPER_CONSOLE: %d ++ => %d" % [ o, self._command_history_current ] )
	
func _on_fadeable_container_on_fading_in( _duration: float ) -> void:
	self.visible = true
	self._block_input = true
	self.game.pause()
	await get_tree().process_frame
	%LineEdit.grab_focus()



func _on_fadeable_container_on_faded_out() -> void:
	self.visible = false
	self._block_input = false


func print_help():
	self.add_history("Help:")
	for c in self._commands:
		var cmd = c as DeveloperCommand
		if cmd == null:
			continue
		var s = cmd.syntax()
		self.add_history( s )
	
func find_command( input: String ) -> DeveloperCommand:
	for c in self._commands:
		var cmd = c as DeveloperCommand
		if cmd == null:
			continue
		var s = cmd.syntax()
		if s == input:
			return cmd
	return null
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	print( "DEVELOPER_CONSOLE: >%s<" % new_text )
	var cmd = find_command( new_text )
	if cmd != null:
		var result = cmd.run( new_text, self.game )
		if result == true:
			self.add_history( new_text )
			self.add_command_history( new_text )
			self._command_history_current = 0
			%LineEdit.clear()
		else:
			self.add_history( ">%s< failed" % new_text )
			
	else:
		self.add_history( new_text )
		%LineEdit.clear()
		match new_text:
			"help":
				self.print_help()
				self.add_command_history( new_text )
				self._command_history_current = 0
			"clear":
				self.clear()
				self.add_command_history( new_text )
				self._command_history_current = 0
			#"resume":
			#	self.game.resume()
			#"reset_player":
			#	self.game.get_player().reset()
			#"give_coins_1000":
			#	self.game.get_player().give_coins( 1000 )
