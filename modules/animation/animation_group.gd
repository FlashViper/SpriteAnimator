@tool
@icon("res://addons/animated_sprite_5d/icons/AnimationGroup.svg")
class_name AnimationGroup
extends Resource

const METADATA := {
	"file": "FlashViper Animation Group",
	"version": "0.1",
}

@export var base_texture : Texture2D
@export var sprite_frames : Array[SpriteFrame] = []
@export var animations : Array[SpriteAnimation] = []
@export var default_animation := ""
@export var mappings : Dictionary = {}


#func _init() -> void:
#	base_texture = null
#	sprite_frames = []
#	animations = []


func get_animation(name: String) -> SpriteAnimation:
	if mappings.is_empty() or mappings == null:
		generate_mappings()
	
	return animations[mappings[name]]


func generate_mappings() -> void:
	for i in animations.size():
		mappings[animations[i].name] = i


func load_from_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var data := JSON.parse_string(file.get_as_text()) as Dictionary
	
	# Validate File
	var meta := data.get("meta", {}) as Dictionary
	if meta.is_empty() or meta.get("file", "") != METADATA.file:
		return
	
	base_texture = load(data.get("texture_path", ""))
	if !base_texture:
		return
	
	sprite_frames = []
	for f in data["frames"]:
		var frame := SpriteFrame.new()
		frame.region = Rect2(
			f["region"].x, 
			f["region"].y, 
			f["region"].w, 
			f["region"].h
		) 
		frame.pivot = Vector2(f["pivot"].x, f["pivot"].y)
		sprite_frames.append(frame)
	generate_mappings()
	
	animations = []
	for a in data["animations"]:
		var anim := SpriteAnimation.new()
		anim.name = a["name"]
		anim.frames = []
		for f in a["frames"]:
			anim.frames.append(int(f))
		anim.loops = a["loops"]
		animations.append(anim)


func to_dictionary() -> Dictionary:
	var result := {}
	
	var frames : Array[Dictionary] = []
	for f in sprite_frames:
		var data := {}
		data["region"] = {
			"x": f.region.position.x,
			"y": f.region.position.y,
			"w": f.region.size.x,
			"h": f.region.size.y,
		}
		data["pivot"] = {
			"x": f.pivot.x,
			"y": f.pivot.y,
		}
		
		frames.append(data)
	
	var sprite_anims : Array[Dictionary] = []
	for a in animations:
		var data := {}
		data["name"] = a.name
		data["frames"] = a.frames
		data["loops"] = a.loops
		
		sprite_anims.append(data)
	
	result["meta"] = METADATA
	result["texture_path"] = ""
	result["frames"] = frames
	result["animations"] = sprite_anims
	
	return result
