class_name OMG_ExportOverides_EditorExportTestPlugin
extends EditorExportPlugin

const NAMES = [
	"application/config/name",
	"application/config/icon"
]

var _original_values: Dictionary[ String, String ] = {}

func _get_name() -> String:
	return "OMG_ExportOverides_EditorExportTestPlugin"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void	:
	for name in NAMES:
		var original = ProjectSettings.get_setting( name, null )
		if original != null:
			self._original_values[ name ] = original

		for feature in features:
			var override = ProjectSettings.get_setting("%s.%s" % [ name, feature ], null)
			if override != null:
				print("Found %s overide for .%s -> %s" % [ name, feature, override])
				ProjectSettings.set_setting(name, override)
			
func _export_end() -> void:
	for name in self._original_values:
		var original = self._original_values[ name ]
		ProjectSettings.set_setting(name, original)
