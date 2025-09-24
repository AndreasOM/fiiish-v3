extends Dialog
class_name FiiishConfirmationDialog

enum Mode {
	CANCEL_CONFIRM,
	CANCEL,
	CONFIRM,
	NONE,
}

signal confirmed
signal cancelled

@onready var description_label: RichTextLabel = %DescriptionLabel

@export var mode: Mode = Mode.NONE : set = set_mode
@onready var cancel_texture_button: TextureButton = %CancelTextureButton
@onready var confirm_texture_button: TextureButton = %ConfirmTextureButton

var _grabbed_initial_focus: bool = false

func _ready() -> void:
	self._update_buttons()
	if OS.get_name() != "HTML5":
		self.description_label.connect("meta_clicked", _on_meta_clicked)

func _on_meta_clicked(meta) -> void:
	OS.shell_open(meta)

func cancel() -> bool:
	var cancellable = false
	match self.mode:
		Mode.CANCEL:
			cancellable = true
		Mode.CANCEL_CONFIRM:
			cancellable = true
		# yes, confirm only dialogs can be confirmed via cancel
		Mode.CONFIRM:
			self.confirmed.emit()
			self.close( 0.3 )
			return true
			
	if cancellable:
		self.cancelled.emit()
		self.close( 0.3 )
		return true
	else:
		return false

func confirm() -> bool:
	var confirmable = false
	match self.mode:
		Mode.CONFIRM:
			confirmable = true
		Mode.CANCEL_CONFIRM:
			confirmable = false # true
			
	if confirmable:
		self.confirmed.emit()
		self.close( 0.3 )
		return true
	else:
		return false

func close( duration: float) -> void:
	fade_out( duration )

func open( duration: float) -> void:
	fade_in( duration )
		
func fade_out( duration: float ) -> void:
	%FadeableContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
	%FadeableContainer.fade_in( duration )


func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	close( 0.3 )


func _on_confirm_button_pressed() -> void:
	confirmed.emit()
	close( 0.3 )
	
func set_title( title: String) -> void:
	%TitleLabel.text = title

func set_description( description: String) -> void:
	%DescriptionLabel.text = description

func set_mode( _mode: Mode):
	mode = _mode
	self._update_buttons()
		
func _update_buttons() -> void:
	if self.cancel_texture_button == null:
		return
	if self.confirm_texture_button == null:
		return
		
	match self.mode:
		Mode.CANCEL:
			self.cancel_texture_button.visible = true
			self.confirm_texture_button.visible = false
		Mode.CONFIRM:
			self.cancel_texture_button.visible = false
			self.confirm_texture_button.visible = true
		Mode.CANCEL_CONFIRM:
			self.cancel_texture_button.visible = true
			self.confirm_texture_button.visible = true
			if !self._grabbed_initial_focus:
				self._grabbed_initial_focus = true
				self.cancel_texture_button.grab_focus.call_deferred()
	
