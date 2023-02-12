extends Control

signal drag_inputted(delta: Vector2)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) > 0:
			drag_inputted.emit(event.relative)
			accept_event()
