extends Control

var viewport_position : Vector2
var viewport_rotation : float
var viewport_scale : float


func _ready() -> void:
	$Preview.animation_updated.connect(on_animation_updated)


func on_animation_updated() -> void:
	var textures : Array[Texture2D] = $Preview.animation
	
	var max_size_x := 0.0
	var max_size_y := 0.0
	for t in textures:
		max_size_x = maxf(max_size_x, t.get_width())
		max_size_y = maxf(max_size_y, t.get_height())
	
	viewport_position = Vector2()
	viewport_rotation = 0
	
	var ratio := minf(size.x / max_size_x, size.y / max_size_y)
	viewport_scale = ratio
	
	update_viewport()


func update_viewport() -> void:
	$Preview.position = size * 0.5 + viewport_position
	$Preview.rotation = viewport_rotation
	$Preview.scale = Vector2.ONE * viewport_scale
