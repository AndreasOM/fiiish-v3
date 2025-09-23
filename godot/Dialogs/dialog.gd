extends Control
class_name Dialog

signal on_closing
signal on_closed
signal on_opening
signal on_opened

var _dialog_manager: DialogManager = null

var _id: DialogIds.Id = DialogIds.Id.INVALID

enum State {
	UNKNOWN,
	OPENING,
	OPEN,
	CLOSING,
	CLOSED,
}

var _state: State = State.UNKNOWN

func set_dialog_manager( dialog_manager: DialogManager ) -> void:
	_dialog_manager = dialog_manager

func set_id( id: DialogIds.Id ) -> void:
	_id = id
	
func get_id() -> DialogIds.Id:
	return self._id

func is_open() -> bool:
	return self._state == State.OPEN

func is_closed() -> bool:
	return self._state == State.CLOSED

func toggle( _duration: float ) -> void:
	push_warning("Toggle not implemented for dialog %s" % self.name )
	
func close( _duration: float ) -> void:
	pass
	
func open( _duration: float ) -> void:
	pass

func closing() -> void:
	on_closing.emit( self )
	
func closed() -> void:
	on_closed.emit( self )

func opening() -> void:
	on_opening.emit( self )

func opened() -> void:
	on_opened.emit( self )
	
func cancel() -> bool:
	return false
	
func confirm() -> bool:
	return false

func _on_fading_in(_duration: float ) -> void:
	opening()

func _on_faded_in( _duration: float ) -> void:
	opened()

func _on_fading_out() -> void:
	closing()

func _on_faded_out() -> void:
	closed()
	
