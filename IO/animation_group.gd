extends Resource

const METADATA := {
	"file": "FlashViper Animation Group",
	"version": "0.1",
}

@export var base_texture : Texture2D
@export var sprite_frames : Array[SpriteFrame]
@export var animations : Array[SpriteAnimation]


func _init() -> void:
	base_texture = null
	sprite_frames = []
	animations = []

class SpriteAnimation extends Resource:
	var name : String
	var frames : Array[int]
	var loops : bool
	
	func size() -> int:
		return (frames.size() if frames != null else 0)

class SpriteFrame extends Resource:
	var region : Rect2i
	var pivot : Vector2


func save_to_file(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(self.to_dictionary(), "\t", false))


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
		frame.region = f["region"]
		frame.pivot = f["pivot"]
		sprite_frames.append(frame)
	
	animations = []
	for a in data["animations"]:
		var anim := SpriteAnimation.new()
		anim.region = a["region"]
		anim.pivot = a["pivot"]
		animations.append(anim)


func to_dictionary() -> Dictionary:
	var result := {}
	
	var frames : Array[Dictionary] = []
	for f in sprite_frames:
		var data := {}
		data["region"] = f.region
		data["pivot"] = f.pivot
		
		frames.append(data)
	
	var sprite_anims : Array[Dictionary] = []
	for a in animations:
		var data := {}
		data["name"] = a.name
		data["frames"] = a.frames
		data["loops"] = a.loops
		
		sprite_anims.append(data)
	
	result["meta"] = METADATA
	result["texture_path"] = base_texture.resource_path
	result["frames"] = frames
	result["animations"] = sprite_anims
	
	return result
