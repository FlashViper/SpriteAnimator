extends Control

signal selected
signal visibility_toggled


func _ready() -> void:
	%VisibilityToggle.pressed.connect(func(): visibility_toggled.emit())
	$Panel.gui_input.connect(gui_input)


func set_animation_name(new: String) -> void:
	%Name.text = new
	name = new


func gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click and event.is_pressed():
				selected.emit()
