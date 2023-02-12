extends Node2D

var rects : Array[Rect2i]
var vertices : Array[Vector2i]

func update_rects(new: Array[Rect2i]) -> void:
	rects = new
	queue_redraw()

func update_vertices(new: Array[Vector2i]) -> void:
	vertices = new
	queue_redraw()

func _draw() -> void:
	if rects != null:
		for r in rects:
			draw_rect(r, Color.WHITE, false, 5)
	
	if vertices != null:
		for v in vertices:
			draw_arc(v, 20, 0, 2 * PI, 20, Color.WHITE, 5)
	
