@tool
@icon("icons/AnimatedSprite5D.svg")
class_name AnimatedSprite5D
extends Node2D

const SpriteAnimation := AnimationGroup.SpriteAnimation
const SpriteFrame := AnimationGroup.SpriteFrame

@export var animation_group : AnimationGroup
@export var fps := 12

@onready var frame_duration := 1.0 / fps

var current_atlas : Texture2D
var frames : Array[SpriteFrame]
var current_anim : SpriteAnimation
var progress : float


func set_group(new: AnimationGroup) -> void:
	animation_group = new
	if animation_group:
		play_animation(new.animations[0].name)
	queue_redraw()


func play_animation(anim_name: String) -> void:
	current_anim = animation_group.get_animation(anim_name)
	progress = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	progress += delta
	queue_redraw()


func _draw() -> void:
	if !current_anim:
		return
	
	var current_frame := int(wrapf(progress * fps, 0, current_anim.frames.size()))
	var frame := animation_group.sprite_frames[current_frame]
	var region := frame.region
	
	draw_texture_rect_region(animation_group.base_texture, Rect2(-frame.pivot, region.size), region)
#	draw_texture(thing2[current_frame], Vector2.DOWN * 300)
