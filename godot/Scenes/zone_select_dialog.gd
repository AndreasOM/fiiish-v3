class_name ZoneSelectDialog
extends Dialog

signal zone_selected

func open( duration: float):
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
