extends Node

var extra_features: Array[ String ] = []

func _ready() -> void:
	var args = OS.get_cmdline_args()
	var lp = " ".join(args)
	
	self._handle_demo( lp )

func _handle_demo( s: String ) -> void:
	if !s.contains("--demo"):
		return
		
	self.add_extra_feature( "demo" )

func has_feature( tag_name: String ) -> bool:
	if OS.has_feature( tag_name ):
		return true

	if extra_features.has( tag_name ):
		return true
		
	return false
	
func add_extra_feature( tag_name: String ) -> void:
	if extra_features.has( tag_name ):
		return
		
	extra_features.push_back( tag_name )
	
