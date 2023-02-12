extends Node

const SpriteAnimation := AnimationGroup.SpriteAnimation
const SpriteFrame := AnimationGroup.SpriteFrame


var source_directory : String
var export_directory : String
var export_filename : String

var raw_sprites : Array[Texture2D]
var animation_data : Array[Dictionary] = []


func clear_data() -> void:
	raw_sprites = []
	animation_data = []


func get_frame(index: int) -> Texture2D:
	return raw_sprites[index]


func add_frame(tex: Texture2D) -> void:
	raw_sprites.append(tex)


func get_animation(index: int) -> Dictionary:
	return animation_data[index]


func add_animation(anim: Dictionary) -> void:
	animation_data.append(anim)


func get_name_list() -> Array[String]:
	var names : Array[String] = []
	for a in animation_data:
		names.append(a.name)
	return names


func get_visible_animations() -> Array[SpriteAnimation]:
	var animations : Array[SpriteAnimation] = []
	
	for a in animation_data:
		if !a["visible"]:
			continue
		
		var anim := SpriteAnimation.new()
		anim.name = a.name
		anim.frames = a.frames
		anim.loops = a.loops
		animations.append(anim)
	
	return animations
