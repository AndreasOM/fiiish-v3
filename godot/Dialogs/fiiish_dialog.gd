class_name FiiishDialog
extends Dialog

var _fader: OmgCanvasItemAlphaFader = null

func _ready() -> void:
	_fader = get_node_or_null("Fader") as OmgCanvasItemAlphaFader
	if _fader != null:
		_fader.fading_in.connect(_on_fader_fading_in)
		_fader.faded_in.connect(opened)
		_fader.fading_out.connect(_on_fader_fading_out)
		_fader.faded_out.connect(closed)

func _on_fader_fading_in(_duration: float) -> void:
	opening()

func _on_fader_fading_out(_duration: float) -> void:
	closing()

func open(duration: float) -> void:
	fade_in(duration)

func close(duration: float) -> void:
	fade_out(duration)

func fade_in(duration: float) -> void:
	if _fader != null:
		_fader.fade_in(duration)

func fade_out(duration: float) -> void:
	if _fader != null:
		_fader.fade_out(duration)
