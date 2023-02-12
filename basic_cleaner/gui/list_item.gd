extends Control

signal clicked
signal visibility_toggled


func _ready() -> void:
	%VisibilityToggle.pressed.connect(func(): visibility_toggled.emit())


func set_animation_name(new: String) -> void:
	%Name.text = new
	name = new


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click and event.is_pressed():
				clicked.emit()


func set_visibility(value: bool) -> void:
	%VisibilityToggle.text = "visible" if value else "hidden"
