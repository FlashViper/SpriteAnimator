#@icon()
extends Node2D

signal animation_updated

@export var fps := 12

var animation : Array[Texture2D] :
	set = set_animation
var loops := true :
	set = set_loops

var current_frame : int
var timer : float
var animation_finished := false


func set_animation(new: Array[Texture2D]) -> void:
	animation = new
	refresh_animation()


func set_loops(new: bool) -> void:
	loops = new
	refresh_animation()


func refresh_animation() -> void:
	current_frame = 0
	timer = 0
	animation_finished = false
	animation_updated.emit()


func _process(delta: float) -> void:
	if animation == null or animation_finished:
		return
	
	timer += delta
	
	if timer > 1.0 / fps:
		current_frame += 1
		
		if current_frame >= animation.size():
			if !loops:
				animation_finished = true
			
			current_frame = 0
			timer = 0
		
		queue_redraw()
		
		timer = 0


func _draw() -> void:
	if animation == null or animation.size() < 1:
		return
	
	var tex := animation[current_frame]
	draw_texture_rect_region(
		tex,
		Rect2(
			-tex.get_size() * 0.5,
			tex.get_size()
		),
		Rect2(
			Vector2(),
			tex.get_size()
		)
	)
