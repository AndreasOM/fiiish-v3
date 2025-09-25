@tool

class_name FiiishUI_ToggleButton
extends CenterContainer


enum ToggleMode {
	AUTO,
	REQUEST,
}

@export var toggle_duration: float = 0.3
@export var toggle_mode: ToggleMode = ToggleMode.AUTO

@export_group("Textures")
@export var a_texture_normal: Texture2D = null : set = set_a_texture_normal
@export var a_texture_focused: Texture2D = null : set = set_a_texture_focused
@export var b_texture_normal: Texture2D = null : set = set_b_texture_normal
@export var b_texture_focused: Texture2D = null : set = set_b_texture_focused

@onready var button_a_fadeable_container: FadeableContainer = %ButtonAFadeableContainer
@onready var button_b_fadeable_container: FadeableContainer = %ButtonBFadeableContainer
@onready var button_a_texture_button: TextureButton = %ButtonATextureButton
@onready var button_b_texture_button: TextureButton = %ButtonBTextureButton

enum ToggleState {
	A,
	B,
	None,
}

var _toggle_state: ToggleState = ToggleState.None


signal toggled( state: ToggleState )
signal toggle_requested( state: ToggleState )

	
func _ready() -> void:
	self.button_a_fadeable_container.fade_in( 0.0 )
	self.button_b_fadeable_container.fade_out( 0.0 )
	self._update_textures()
	self._update_focus()
	if self.name != "FiiishUI_ToggleButton": #:HACK:
		self.button_a_texture_button.name = "%s_%s" % [ self.name, self.button_a_texture_button.name ]
		self.button_b_texture_button.name = "%s_%s" % [ self.name, self.button_b_texture_button.name ]

func _patch_node_path( np: NodePath ) -> NodePath:
	if np == NodePath():
		return NodePath()
		
	return NodePath( "../../%s" % np )
	
func _update_focus() -> void:
	self.button_a_texture_button
	self.button_a_texture_button.focus_neighbor_left	= _patch_node_path( self.focus_neighbor_left )
	self.button_a_texture_button.focus_neighbor_right	= _patch_node_path( self.focus_neighbor_right )
	self.button_a_texture_button.focus_neighbor_top		= _patch_node_path( self.focus_neighbor_top )
	self.button_a_texture_button.focus_neighbor_bottom	= _patch_node_path( self.focus_neighbor_bottom )
	self.button_a_texture_button.focus_next				= _patch_node_path( self.focus_next )
	self.button_a_texture_button.focus_previous			= _patch_node_path( self.focus_previous )
	self.button_b_texture_button.focus_neighbor_left	= _patch_node_path( self.focus_neighbor_left )
	self.button_b_texture_button.focus_neighbor_right	= _patch_node_path( self.focus_neighbor_right )
	self.button_b_texture_button.focus_neighbor_top		= _patch_node_path( self.focus_neighbor_top )
	self.button_b_texture_button.focus_neighbor_bottom	= _patch_node_path( self.focus_neighbor_bottom )
	self.button_b_texture_button.focus_next				= _patch_node_path( self.focus_next )
	self.button_b_texture_button.focus_previous			= _patch_node_path( self.focus_previous )
	
func _update_textures() -> void:
	if self.button_a_texture_button == null:
		return
	if self.button_b_texture_button == null:
		return
		
	self.button_a_texture_button.texture_normal = self.a_texture_normal
	self.button_a_texture_button.texture_focused = self.a_texture_focused
	self.button_b_texture_button.texture_normal = self.b_texture_normal
	self.button_b_texture_button.texture_focused = self.b_texture_focused

func set_a_texture_normal( t: Texture2D ) -> void:
	a_texture_normal = t
	self._update_textures()
	
func set_a_texture_focused( t: Texture2D ) -> void:
	a_texture_focused = t
	self._update_textures()
	
func set_b_texture_normal( t: Texture2D ) -> void:
	b_texture_normal = t
	self._update_textures()
	
func set_b_texture_focused( t: Texture2D ) -> void:
	b_texture_focused = t
	self._update_textures()
		
func goto_a() -> void:
	self.button_a_fadeable_container.fade_in( toggle_duration )
	self.button_b_fadeable_container.fade_out( toggle_duration )
	self._toggle_state = ToggleState.A
	if self.button_b_texture_button.has_focus():
		self.button_a_texture_button.grab_focus.call_deferred()

func goto_b() -> void:
	self.button_a_fadeable_container.fade_out( toggle_duration )
	self.button_b_fadeable_container.fade_in( toggle_duration )
	self._toggle_state = ToggleState.B
	if self.button_a_texture_button.has_focus():
		self.button_b_texture_button.grab_focus.call_deferred()

func toggle_fade( duration: float ) -> void:
	match self._toggle_state:
		ToggleState.A:
			self.button_a_fadeable_container.toggle_fade( duration )
		ToggleState.B:
			self.button_b_fadeable_container.toggle_fade( duration )
		
func fade_in( duration: float) -> void:
	match self._toggle_state:
		ToggleState.A:
			self.button_a_fadeable_container.fade_in( duration )
		ToggleState.B:
			self.button_b_fadeable_container.fade_in( duration )
	
func fade_out( duration: float) -> void:
	self.button_a_fadeable_container.fade_out( duration )
	self.button_b_fadeable_container.fade_out( duration )

func _on_a_pressed() -> void:
	print("A pressed")
	match self.toggle_mode:
		ToggleMode.AUTO:
			goto_b()
			self.button_b_fadeable_container.grab_focus.call_deferred()
			toggled.emit(ToggleState.B)
		ToggleMode.REQUEST:
			self.toggle_requested.emit( ToggleState.A )

func _on_b_pressed() -> void:
	print("B pressed")
	match self.toggle_mode:
		ToggleMode.AUTO:
			goto_a()
			self.button_a_fadeable_container.grab_focus.call_deferred()
			toggled.emit(ToggleState.A)
		ToggleMode.REQUEST:
			self.toggle_requested.emit( ToggleState.A )
			


func _on_focus_entered() -> void:
	match self._toggle_state:
		ToggleState.A:
			if self.button_a_texture_button.focus_mode != FocusMode.FOCUS_NONE:
				self.button_a_texture_button.grab_focus.call_deferred()
		ToggleState.B:
			if self.button_b_texture_button.focus_mode != FocusMode.FOCUS_NONE:
				self.button_b_texture_button.grab_focus.call_deferred()
