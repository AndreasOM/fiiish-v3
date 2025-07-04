class_name OMG_ExportOverides_EditorExportTestPlugin
extends EditorExportPlugin


const NAME="application/config/name"
var _application_config_name: String = ""

func _get_name() -> String:
	return "OMG_ExportOverides_EditorExportTestPlugin"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void	:
	self._application_config_name = ProjectSettings.get_setting( NAME )
	for f in features:
		var s = ProjectSettings.get_setting("%s.%s" % [ NAME, f ], null)
		if s != null:
			print("Found %s overide for .%s -> %s" % [ NAME, f, s])
			ProjectSettings.set_setting(NAME, s)

func _export_end() -> void:
	if !self._application_config_name.is_empty():
		ProjectSettings.set_setting(NAME, self._application_config_name)
