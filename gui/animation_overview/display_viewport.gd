extends Control

var viewport_position : Vector2
var viewport_rotation : float
var viewport_scale : float


func _ready() -> void:
	$Preview.animation_updated.connect(on_animation_updated)


func on_animation_updated() -> void:
	var textures : Array[Texture2D] = $Preview.animation
	
	var max_size := Vector2()
	for t in textures:
		max_size.x = maxf(max_size.x, t.get_width())
		max_size.y = maxf(max_size.y, t.get_height())
	
	viewport_position = Vector2()
	viewport_rotation = 0
	
	var max_index := size.min_axis_index()
	viewport_scale = size[max_index] / max_size[max_index]
	
	update_viewport()


func update_viewport() -> void:
	$Preview.position = size * 0.5 + viewport_position
	$Preview.rotation = viewport_rotation
	$Preview.scale = Vector2.ONE * viewport_scale
