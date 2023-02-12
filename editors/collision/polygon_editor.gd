extends Control

@export var vertex_texture : Texture2D
@export var base_color := Color.RED
@export var dash_length := 10.0

var polygon := PackedVector2Array()
@onready var polygon_color := base_color * Color(1,1,1,0.3)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if event.ctrl_pressed:
						insert_vertex(event.position)
					else:
						create_vertex(event.position)
			MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					print(polygon.size())
					for i in polygon.size():
						if (polygon[-1 - i] - event.position).length() < 15:
							delete_vertex(polygon.size() - 1 - i)

func get_shape() -> Shape2D:
	var shape := ConvexPolygonShape2D.new()
	shape.points = polygon
	return shape

func get_position() -> Vector2:
	return Vector2()

func create_vertex(point: Vector2) -> void:
	polygon.append(point)
	queue_redraw()

func insert_vertex(point: Vector2) -> void:
	var best_index := polygon.size() - 1
	var min_distance := INF
	
	for i in polygon.size() - 1:
		var dist1 := (point - polygon[i]).length()
		var dist2 := (point - polygon[i  + 1]).length()
		if dist1 + dist2 < min_distance:
			min_distance = dist1 + dist2
			best_index = i + 1
	
	polygon.insert(best_index, point)
	queue_redraw()

func delete_vertex(index: int) -> void:
	polygon.remove_at(index)
	queue_redraw()

func _draw() -> void:
	if polygon.size() > 2:
		draw_colored_polygon(polygon, polygon_color)
	
	if polygon.size() > 1:
		draw_polyline(polygon, base_color, 3)
		
		var dashed_initial := polygon[-1]
		var dashed_final := polygon[0]
		var dir := dashed_final - dashed_initial
		var dashes := floori(dir.length() / dash_length)

		var line := PackedVector2Array()
		for i in dashes - 1:
			line.append(dashed_initial + dir.normalized() * i * dash_length)
		line.append(dashed_final)
		draw_multiline(line, base_color, 4.0)
	
	for p in polygon:
		draw_circle(p, 9, base_color)
