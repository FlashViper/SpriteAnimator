extends "property_editor.gd"

const COLLIDER_ALPHA := 0.2
enum {
	DRAG_POSITION,
	DRAG_RADIUS,
}


var colliders : Array[Dictionary]

var is_dragging : bool
var drag_root : Vector2
var drag_target := -1
var drag_mode : int 

var colors := {}

func _ready() -> void:
	initialize(%GUI)
	add_color_for_id(0)


func add_color_for_id(id: int) -> void:
	var hue := randf_range(0.0, 1.0)
	var saturation := randf_range(0.75, 1.0)
	var value := randf_range(0.5, 1.0)
	
	colors[id] = Color.from_hsv(hue, saturation, value)


func _on_mouse_down(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = true
		drag_root = event.position
		if !event.ctrl_pressed:
			for i in colliders.size():
				if (event.position - colliders[i].position).length() < colliders[i].radius + 20:
					if abs(colliders[i].radius - (event.position - colliders[i].position).length()) < 20:
						drag_mode = DRAG_RADIUS
					else:
						drag_mode = DRAG_POSITION
					drag_target = i
					break


func _on_mouse_up(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = false
		if drag_target < 0:
			colliders.append({
				"position": drag_root,
				"radius": (event.position - drag_root).length(),
				"id": 0
			})
		
		drag_target = -1
		canvas.queue_redraw()
	

func _on_mouse_drag(event: InputEventMouseMotion) -> void:
	if is_dragging:
		if drag_target >= 0:
			match drag_mode:
				DRAG_POSITION:
					colliders[drag_target].position += event.relative
				DRAG_RADIUS:
					var dir_to_center: Vector2 = event.position - colliders[drag_target].position
					colliders[drag_target].radius += event.relative.dot(dir_to_center.normalized())
		canvas.queue_redraw() 



func _draw_controls() -> void:
	var ids : Array[int] = []
	for c in colliders:
		if !ids.has(c.id):
			ids.append(c.id)
	
	for c in colliders:
		var base_color : Color = colors[c.id]
		var fill_color : Color = Color(base_color, COLLIDER_ALPHA)
		
		canvas.draw_circle(c.position, c.radius, fill_color)
		canvas.draw_arc(c.position, c.radius, 0, TAU, 40, base_color, 5)
	
	if is_dragging and drag_target < 0:
		var base_color := Color.DARK_SLATE_GRAY
		var fill_color := Color(base_color, COLLIDER_ALPHA)
		
		canvas.draw_circle(drag_root, (canvas.get_local_mouse_position() - drag_root).length(), fill_color)
		canvas.draw_arc(drag_root, (canvas.get_local_mouse_position() - drag_root).length(), 0, TAU, 40, base_color, 5)
