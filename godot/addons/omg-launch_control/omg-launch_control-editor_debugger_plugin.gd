@tool
extends EditorPlugin

class OMG_LaunchControl_EditorDebuggerPlugin extends EditorDebuggerPlugin:

#	func _has_capture(capture):
#		# Return true if you wish to handle messages with the prefix "my_plugin:".
##		return capture == "omg-launch_control"
#		return false

#	func _capture(message, data, session_id):
##		if message == "omg-launch_control:launch_parameter_used":
##			#get_session(session_id).send_message("my_plugin:echo", data)
##			print("launch_parameter_used:", data)
##			# ProjectSettings.set_setting("addons/omg-launch_control/launch_parameter", "")
##			ProjectSettings.set_setting("editor/run/main_run_args", "")
##			ProjectSettings.save()
##
##			return true
#		return false

	func _setup_session(session_id):
		var session = get_session(session_id)
		# Listens to the session started and stopped signals.
		session.started.connect(func (): print("Session started"))
		#session.stopped.connect(func (): print("Session stopped"))
		session.stopped.connect( _on_session_stopped )
		
	func _on_session_stopped() -> void:
		print("Session stopped - removing main_run_args")
		ProjectSettings.set_setting("editor/run/main_run_args", "")
		ProjectSettings.save()
		EditorInterface.set_movie_maker_enabled( false )
		

var debugger = OMG_LaunchControl_EditorDebuggerPlugin.new()

func _enter_tree():
	print("Launch Control - Editor Plugin - Enter")
	add_debugger_plugin(debugger)

func _exit_tree():
	print("Launch Control - Editor Plugin - Exit")
	remove_debugger_plugin(debugger)
