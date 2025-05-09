extends Control
class_name Dialog

signal on_closing
signal on_closed
signal on_opening
signal on_opened

var _dialog_manager: DialogManager = null

func set_dialog_manager( dialog_manager: DialogManager ):
	_dialog_manager = dialog_manager
	
func toggle( _duration: float ):
	push_warning("Toggle not implemented for dialog %s" % self.name )
	pass
	
func close( _duration: float ):
	pass
	
func open( _duration: float ):
	pass

func closing():
	on_closing.emit( self )
	
func closed():
	on_closed.emit( self )

func opening():
	on_opening.emit( self )

func opened():
	on_opened.emit( self )
	
func _on_fading_in(_duration: float ) -> void:
	opening()

func _on_faded_in( _duration: float ) -> void:
	opened()

func _on_fading_out() -> void:
	closing()

func _on_faded_out() -> void:
	closed()
	
