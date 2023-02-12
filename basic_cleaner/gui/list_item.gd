extends Control

signal clicked


func set_animation_name(new: String) -> void:
	%Name.text = new
	name = new


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click and event.is_pressed():
				clicked.emit()
