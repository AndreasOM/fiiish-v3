extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var s = 0.5
	
	# DisplayServer.window_set_size( s*Vector2( 1920.0, 1080.0 ) )
	#get_window().set_size( Vector2i( s*Vector2( 1920.0, 1080.0 ) ) )
	# get_tree().get_root().size = s*Vector2( 1920.0, 1080.0 )
	var dcd = %DialogManager.open_dialog(DialogIds.Id.DEVELOPER_CONSOLE_DIALOG, 0.0)
	dcd.fade_out( 0.0 )
	grab_focus.call_deferred()
	$Game.resume()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
