@tool
extends Control

@export var texture : Texture2D :
	set(new):
		texture = new
		queue_redraw()
#@export var rectangle_size := 64

var draw_offset : Vector2 :
	set(new):
		draw_offset = new
		queue_redraw()

func _draw() -> void:
	if !texture:
		return
	
	draw_texture_rect(texture, Rect2(Vector2(), size), true)
	
#	var local_offset := draw_offset.posmod(rectangle_size)
#	print(local_offset)
	
#	for x in ceili(size.x):
#		for y in ceili(size.y):
#			if (x % 2) ^ (y % 2):
#				var pos := Vector2(x, y) * rectangle_size - local_offset
#				draw_rect(Rect2(pos, Vector2.ONE * rectangle_size), color2)

func offset(by: Vector2) -> void:
	draw_offset = draw_offset + by
