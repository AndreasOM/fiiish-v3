extends Control
class_name Dialog

var _dialog_manager: DialogManager = null

func set_dialog_manager( dialog_manager: DialogManager ):
	_dialog_manager = dialog_manager
	
func toggle( duration: float ):
	pass
	
func close( duration: float ):
	pass
	
func open( duration: float ):
	pass
