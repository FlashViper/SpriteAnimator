extends Node2D

const AnimationGroup := preload("res://IO/animation_group.gd")
const SpriteFrame := AnimationGroup.SpriteFrame
const SpriteAnim := AnimationGroup.SpriteAnimation

@export var fps := 12
@export var animation_group : AnimationGroup
@export var debug_shapes := false

var current_animation : SpriteAnim
var current_frame := 0
var timer := 0.0

func set_group(new_group: AnimationGroup) -> void:
	current_frame = 0
	timer = 0.0
	current_animation = null
	
	animation_group = new_group


func play(animation_name: String) -> void:
	current_frame = 0
	timer = 0.0
	
	print(animation_group.animations.size())
	for a in animation_group.animations:
		if a.name == animation_name:
			current_animation = a
			return
	
	current_animation = null


func _process(delta: float) -> void:
	if current_animation == null or animation_group == null:
		return
	
	timer += delta
	current_frame = int(timer * fps) % current_animation.size()
	
	queue_redraw()


func _draw() -> void:
	if animation_group == null:
		return
	
	var tex := animation_group.base_texture
	var a : SpriteFrame
	
	if current_animation == null:
		a = animation_group.sprite_frames[0]
	else:
		a = animation_group.sprite_frames[current_animation.frames[current_frame]]
	
	draw_texture_rect_region(
		tex, 
		Rect2(-a.pivot, a.region.size), 
		a.region
	)
	
	if debug_shapes:
		draw_rect(Rect2(-a.pivot, a.region.size), Color.WHITE, false)
		draw_arc(-a.pivot, 5, 0, 2 * PI, 20, Color.RED, 5)
		draw_arc(Vector2(), 5, 0, 2 * PI, 20, Color.GREEN, 5)
