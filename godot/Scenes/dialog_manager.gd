extends Control
class_name DialogManager

@export var game: Game = null

var _dialog_configs: Dictionary = {
	DialogIds.Id.RESULT_DIALOG: preload("res://Dialogs/result_dialog.tscn"),
	DialogIds.Id.SETTING_DIALOG: preload("res://Dialogs/setting_dialog.tscn"),
	DialogIds.Id.SKILL_UPGRADE_DIALOG: preload("res://Dialogs/skill_upgrade_dialog.tscn"),
}

var _dialogs: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# $SkillUpgradeDialog.fade_out( 0.0 )
	for id in _dialog_configs.keys():
		var dc = _dialog_configs.get( id )
		var d = dc.instantiate()
		var dialog = d as Dialog
		if dialog == null:
			push_warning( "%d is not a dialog" % [ id ] )
			continue
		#if dialog.has_method( "set_dialog_manager" ):
		dialog.set_dialog_manager( self )
		if dialog.has_method( "set_game" ):
			dialog.set_game( game );
		dialog.on_closing.connect( on_dialog_closing )
		dialog.on_closed.connect( on_dialog_closed )
		dialog.on_opening.connect( on_dialog_opening )
		dialog.on_opened.connect( on_dialog_opened )
		dialog.close( 0.0 )
		# dialog.override_z_index( 0 )
		self.add_child( dialog )
		_dialogs[ id ] = dialog
			
	# open_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )

func on_dialog_closing( dialog: Dialog ):
	print( "on_dialog_closing %s" % dialog.name )

func on_dialog_closed( dialog: Dialog ):
	print( "on_dialog_closed %s" % dialog.name )
	dialog.visible = false

func on_dialog_opening( dialog: Dialog ):
	print( "on_dialog_opening %s" % dialog.name )
	dialog.visible = true

func on_dialog_opened( dialog: Dialog ):
	print( "on_dialog_opened %s" % dialog.name )
	
func _on_skills_upgrade_button_pressed() -> void:
	print("Skills upgrade button pressed")
	open_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )

func toggle_dialog( id: DialogIds.Id, duration: float):
	var dialog = _dialogs.get( id ) as Dialog
	if dialog != null:
		dialog.toggle( duration )
	else:
		push_warning("Dialog %d not found for toggle" % id )
	
func open_dialog( id: DialogIds.Id, duration: float):
	var dialog = _dialogs.get( id ) as Dialog
	if dialog != null:
		print("Opening dialog %d" % id)
		dialog.open( duration )
		dialog.visible = true
	else:
		push_warning("Dialog %d not found for open" % id )

func close_dialog( id: DialogIds.Id, duration: float):
	var dialog = _dialogs.get( id ) as Dialog
	if dialog != null:
		print("Closing dialog %d" % id)
		dialog.close( duration )
		dialog.visible = false
	else:
		push_warning("Dialog %d not found for close" % id )
	

func _on_game_state_changed(state: Game.State) -> void:
	match state:
		Game.State.DYING:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			open_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		Game.State.RESPAWNING:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		Game.State.WAITING_FOR_START:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		Game.State.SWIMMING:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		_:
			pass
