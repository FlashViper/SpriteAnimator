extends CanvasItem


@export var rect_scale := 10.0
var the_datas : Array[Dictionary]

func redraw(data: Dictionary) -> void:
	the_datas = []
	for f in data["frames"]:
		the_datas.append(f)
	queue_redraw()

func _draw() -> void:
	if the_datas.size() > 0:
		draw_rect(Rect2(0,0, 5000, 2000), Color.BLACK)
	for d in the_datas:
		var region = d["atlas_region"]
		var r := Rect2i(region.position * rect_scale, region.size * rect_scale)
		draw_set_transform_matrix(Transform2D())
		draw_rect(r, Color.YELLOW, false, 5.0)
		draw_circle(d["pivot"], 10, Color.BLUE)
		draw_set_transform_matrix(Transform2D().scaled(rect_scale * Vector2.ONE))
		draw_texture_rect_region(d["source_texture"], d["atlas_region"], d["source_region"])
