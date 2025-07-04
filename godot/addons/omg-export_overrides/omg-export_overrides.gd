@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var export_plugin = OMG_ExportOverides_EditorExportTestPlugin.new()
	add_export_plugin( export_plugin )

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
