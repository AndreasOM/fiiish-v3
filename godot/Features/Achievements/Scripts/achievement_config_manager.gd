class_name AchievementConfigManager
extends Node

var _configs: Dictionary[ String, AchievementConfig ] = {}

func _init() -> void:
	self.reload()
	
func reload() -> void:
	self._configs.clear()
	var folder = "res://Features/Achievements/AchievementConfigs/"
	var configs = ResourceLoader.list_directory( folder )
	for cn in configs:
		if !cn.ends_with( ".tres" ):
			continue
		var fcn = "%s/%s" % [ folder, cn ]
		var c = load( fcn )
		var cfg = c as AchievementConfig
		if cfg == null:
			continue
		print("Achievement Config: %s" % cn)
		var n = cfg.id
		if self._configs.has( n ):
			push_warning("Duplicate achievement config %s from %s" % [ n, cn ])
			continue
		self._configs[ n ] = cfg

	print( "Loaded %d achievement configs." % self._configs.size() )
	
func get_keys() -> Array[ String ]:
	return self._configs.keys()
	
func get_config( id: String ) -> AchievementConfig:
	return self._configs.get( id, null )
