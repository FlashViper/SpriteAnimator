extends MarginContainer

signal clicked
signal double_clicked


func _ready() -> void:
	mouse_entered.connect(set_hover_state.bind(true))
	mouse_exited.connect(set_hover_state.bind(false))


func set_hover_state(state: bool) -> void:
	var t := create_tween()
	t.tween_property($PanelContainer, "self_modulate:a", 0.75 if state else 0.3, 0.05)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				double_clicked.emit()
			else:
				clicked.emit()
