extends Node

var canvas : Control


func initialize(p_canvas: Control) -> void:
	if canvas:
		canvas.gui_input.disconnect(on_canvas_input)
		canvas.draw.disconnect(draw)
	
	canvas = p_canvas
	canvas.draw.connect(draw)
	canvas.gui_input.connect(on_canvas_input)


func on_canvas_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				_on_mouse_down(event)
			else:
				_on_mouse_up(event)
	
	if event is InputEventMouseMotion:
		_on_mouse_drag(event)


func draw() -> void:
	if canvas:
		_draw_controls()


func _on_mouse_down(event: InputEventMouseButton) -> void: pass
func _on_mouse_up(event: InputEventMouseButton) -> void: pass
func _on_mouse_drag(event: InputEventMouseMotion) -> void: pass
func _draw_controls() -> void: pass

func _get_data_id() -> String: return ""
func _parse_data(data: Dictionary) -> void: pass
func _store_data() -> Dictionary: return {}
