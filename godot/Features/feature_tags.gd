extends Node

var extra_features: Array[ String ] = []
var removed_features: Array[ String ] = []

func _ready() -> void:
	var args = OS.get_cmdline_args()
	var lp = " ".join(args)
	
	self._handle_demo( lp )
	self._handle_steam()

func _handle_demo( s: String ) -> void:
	if !s.contains("--demo"):
		return
		
	self.add_extra_feature( "demo" )

func _handle_steam( ) -> void:
	var ir = Steam.get_steam_init_result()
	var status = ir.get( "status", null )
	if status == 0:
		self.add_extra_feature( "steam" )
	else:
		self.remove_feature( "steam" )

	
func has_feature( tag_name: String ) -> bool:
	if removed_features.has( tag_name ):
		return false
		
	if OS.has_feature( tag_name ):
		return true

	if extra_features.has( tag_name ):
		return true
		
	return false
	
func add_extra_feature( tag_name: String ) -> void:
	if extra_features.has( tag_name ):
		return
		
	extra_features.push_back( tag_name )
	

func remove_feature( tag_name: String ) -> void:
	if removed_features.has( tag_name ):
		return
		
	removed_features.push_back( tag_name )
