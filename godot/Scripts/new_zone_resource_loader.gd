extends ResourceFormatLoader
class_name NewZoneResourceLoader


func _init() -> void:
	pass
	
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["nzne"])

func _get_resource_type(path: String) -> String:
	# print("NewZoneResourceLoader: ", path )
	if path.ends_with(".nzne"):
		return "NewZone"
	else:
		return ""

func _handles_type(type: StringName) -> bool:
	return type == "Resource"
	
func _load(_path: String, original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	# print("!!!!! Load ", original_path)
	var s = Serializer.new()
	s.load_file( original_path )

	var n = NewZone.new()
	n.serialize( s )
	return n
