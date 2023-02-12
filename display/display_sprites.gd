extends Control

@export var fps := 12
@export var loop := true
@export var viewport_offset : Vector2
@export var viewport_scale := 1.0

@onready var time_per_frame := 1.0 / fps
@onready var current_frame := 0
@onready var animation_time := 0.0

var textures : Array[Texture2D]


func _ready() -> void:
	pause()


func _process(delta: float) -> void:
	animation_time += delta
	
	if animation_time > time_per_frame:
		animation_time = 0
		current_frame += 1
		if current_frame >= textures.size():
			if loop:
				current_frame = 0
			else:
				pause()
		
		queue_redraw()


func play() -> void:
	set_process(true)


func pause() -> void:
	animation_time = 0
	set_process(false)


func set_textures(new: Array[Texture2D]) -> void:
	textures = new
	
	viewport_offset = Vector2()
	
	var max_size := Vector2.ONE
	for t in textures:
		max_size = max(max_size, t.get_size())
	viewport_scale = size[size.min_axis_index()] / max_size[size.min_axis_index()]
	
	play()


func get_pivot(index: int) -> Vector2:
#	var center := 0.5 * size
	return -0.5 * textures[index].get_size()


func offset(by: Vector2) -> void:
	viewport_offset += by
	queue_redraw()


func _draw() -> void:
	if current_frame >= textures.size():
		return
	
	draw_set_transform(size * 0.5 + viewport_offset, 0, Vector2.ONE * viewport_scale)
	
	draw_texture(
		textures[current_frame], 
		get_pivot(current_frame)
	)
