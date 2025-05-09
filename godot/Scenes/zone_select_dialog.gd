class_name ZoneSelectDialog
extends Dialog

enum Mode {
	LOAD,
	SAVE_AS,
}
signal zone_selected( ZoneSelectDialog, String )
const ZONE_SELECTION_ELEMENT = preload("res://Dialogs/ZoneSelection/zone_selection_element.tscn")
const ZONE_NAMING_ELEMENT = preload("res://Dialogs/ZoneSelection/zone_naming_element.tscn")

@onready var elements: VBoxContainer = %Elements

@export var filter_prefixes: Array[ String ] = []
@export var mode: Mode = Mode.LOAD

func clear_filter_prefixes() -> void:
	self.filter_prefixes = []

func add_filter_prefix( prefix: String ) -> void:
	if self.filter_prefixes.find( prefix ) != -1:
		return
	self.filter_prefixes.push_back( prefix )
	
func _ready() -> void:
	pass
	
func _allowed( filename: String ) -> bool:
	if self.filter_prefixes.is_empty():
		return true
	
	for p in self.filter_prefixes:
		if filename.begins_with( p ):
			return true
			
	return false
	
func update_zones() -> void:
	for c in %Elements.get_children():
		%Elements.remove_child( c )
		c.queue_free()
		
	if self.mode == ZoneSelectDialog.Mode.SAVE_AS:
		var zne: ZoneNamingElement = ZONE_NAMING_ELEMENT.instantiate()
		zne.title = "New File:"
		zne.filename = ""
		zne.named.connect( _on_zone_naming_element_selected )
		%Elements.add_child( zne )
		
	var game = self._dialog_manager.game
	var zone_config_manager: ZoneConfigManager = game.get_game_manager().get_zone_config_manager()

	var zone_filenames = zone_config_manager.get_zone_filenames()
	for zf in zone_filenames:
		var filename = zf
		if !self._allowed( filename ):
			continue
		var zone = zone_config_manager.get_zone_by_filename( filename )
		var title = zone.name
		self._add_selection( title, filename )

	#self._add_selection("Tunnel", "classic-0010_Tunnel.nzne" )
	#self._add_selection("Funnel", "classic-0020_Funnel.nzne" )
	

func _add_selection( title: String, filename: String ) -> void:
	var zse: ZoneSelectionElement = ZONE_SELECTION_ELEMENT.instantiate()
	zse.title = title
	zse.filename = filename
	zse.selected.connect( _on_zone_selection_element_selected )
	%Elements.add_child( zse )
	
	
func open( duration: float):
	self.update_zones()
	fade_in( duration )

func close( duration: float):
	fade_out( duration )

func toggle( duration: float ):
	toggle_fade( duration )

func toggle_fade( duration: float ):
	%FadeablePanelContainer.toggle_fade( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )


func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()

func _on_anchor_texture_button_pressed() -> void:
	self.zone_selected.emit( "classic-5001_Anchor.nzne")


func _on_i_love_fiiish_texture_button_pressed() -> void:
	self.zone_selected.emit( "classic-0000_ILoveFiiish.nzne")

func _on_close_button_pressed() -> void:
	self.close( 0.3 )

func _on_zone_selection_element_selected( e: ZoneSelectionElement ) -> void:
	var f = e.filename
	self.zone_selected.emit( self, f )

func _on_zone_naming_element_selected( e: ZoneNamingElement ) -> void:
	var f = e.filename
	self.zone_selected.emit( self, f )
