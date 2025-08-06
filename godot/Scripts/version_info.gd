extends Node

const VERSION_FILE: String = "res://Resources/version_info.txt"

var commit = "local"
var build = "local"
var version = "v0.0.0"
var suffix = "local"

func _ready() -> void:
	var version_info = FileAccess.get_file_as_string( VERSION_FILE )
	var vlines = version_info.split("\n")
	
	for l in vlines:
		print( l )
		var p = l.split("=")
		if p.size() != 2:
			print("Skipping %s" % l)
			continue
		match p[ 0 ]:
			"commit": self.commit = p[ 1 ]
			"build": self.build = p[ 1 ]
			"version": self.version = p[ 1 ]
			"suffix": self.suffix = p[ 1 ]
			_:
				pass
	
func print() -> void:
	print( "Version : %s" % self.version )
	print( "Commit  : %s" % self.commit )
	print( "Build   : %s" % self.build )
	print( "Suffix  : %s" % self.suffix )
