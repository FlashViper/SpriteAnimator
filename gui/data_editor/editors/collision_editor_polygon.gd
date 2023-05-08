# Polygon Editor
extends "property_editor.gd"

var polygons : Array[Dictionary] = []
var current_polygon := -1


func _ready() -> void:
	initialize(%GUI)


func _on_mouse_down(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if current_polygon < 0:
			current_polygon = polygons.size()
			polygons.append({
				"position": event.position,
				"points": [event.position]
			})
		else:
			polygons[current_polygon].points.append(event.position)
		
		canvas.queue_redraw()

#func _on_mouse_up(event: InputEventMouseButton) -> void: pass
#func _on_mouse_drag(event: InputEventMouseMotion) -> void: pass


func _draw_controls() -> void:
	for p in polygons:
		var line_color := Color.BLUE_VIOLET
		var fill_color := Color(line_color, 0.2)
		
		if p.points.size() > 2:
			canvas.draw_colored_polygon(p.points, fill_color)
		if p.points.size() > 1:
			canvas.draw_polyline(p.points, line_color, 5)
		
		for point in p.points:
			canvas.draw_circle(point, 10, line_color)


func _get_data_id() -> String:
	return "collision_polygon"


func _store_data() -> Dictionary:
	var data := {}
	for p in polygons:
		pass
