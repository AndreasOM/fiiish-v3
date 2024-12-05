extends Control
class_name Dialog

signal on_closing
signal on_closed
signal on_opening
signal on_opened

var _dialog_manager: DialogManager = null

func set_dialog_manager( dialog_manager: DialogManager ):
	_dialog_manager = dialog_manager
	
func toggle( duration: float ):
	pass
	
func close( duration: float ):
	pass
	
func open( duration: float ):
	pass

func closing():
	on_closing.emit( self )
	
func closed():
	on_closed.emit( self )

func opening():
	on_opening.emit( self )

func opened():
	on_opened.emit( self )
