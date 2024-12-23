extends Dialog

@export var game: Game = null
@export var max_history: int = 10

var _block_input: bool = false

var _history: Array = []

func close( duration: float):
	fade_out( duration )

func open( duration: float):
	fade_in( duration )
		
func fade_out( duration: float ):
	%FadeableContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeableContainer.fade_in( duration )

func set_game( game: Game):
	self.game = game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.clear()


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
		elif event.is_action("cursor_up"):
			get_viewport().set_input_as_handled()
			if _history.size() > 0:
				var l = _history.back()
				%LineEdit.text = l
		elif event.is_action("cursor_down"):
			get_viewport().set_input_as_handled()
			%LineEdit.text = ""
		
func clear():
	%RichTextLabel.clear()
	self._history.clear()
	self.update_history()
	pass

func update_history():
	var h = "\n".join( self._history)
	%RichTextLabel.text = h
	
func add_history( line: String ):
	self._history.push_back( line )
	
	while self._history.size() > self.max_history:
		self._history.pop_front()
		
	self.update_history()
		
func _on_fadeable_container_on_fading_in() -> void:
	self.visible = true
	self._block_input = true
	self.game.pause()
	await get_tree().process_frame
	%LineEdit.grab_focus()



func _on_fadeable_container_on_faded_out() -> void:
	self.visible = false
	self._block_input = false


func _on_line_edit_text_submitted(new_text: String) -> void:
	print( new_text )
	self.add_history( new_text )
	%LineEdit.clear()
	match new_text:
		"clear":
			self.clear()
		"resume":
			self.game.resume()
		"reset_player":
			self.game.get_player().reset()
		"give_coins_1000":
			self.game.get_player().give_coins( 1000 )
