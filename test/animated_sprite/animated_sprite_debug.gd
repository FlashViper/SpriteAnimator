extends Node2D


@export var animation_group : AnimationGroup
var current_anim : SpriteAnimation

func debug_animation(anim_name: String) -> void:
	if animation_group:
		current_anim = animation_group.get_animation(anim_name)
		queue_redraw()


func _draw() -> void:
	if !(animation_group and current_anim):
		return
	
	var root_pos := Vector2()
	for f in current_anim.frames:
		var frame := animation_group.sprite_frames[f]
		draw_texture_rect_region(
			animation_group.base_texture, 
			Rect2(root_pos, frame.region.size), 
			frame.region
		)
		
		root_pos.x += frame.region.size.x + 10
