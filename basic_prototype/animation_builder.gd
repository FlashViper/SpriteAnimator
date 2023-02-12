extends Node

const SUPPORTED := ["png", "jpg", "jpeg", "webp"]

const TexturePacker := preload("res://IO/texture_packer.gd")
const AnimationGroup := preload("res://IO/animation_group.gd")
const SpriteFrame := AnimationGroup.SpriteFrame
const SpriteAnim := AnimationGroup.SpriteAnimation

func create_from_dir(directory: String) -> AnimationGroup:
	var group := AnimationGroup.new()
	
	var animation_names := scan_for_directories(directory)
	var textures : Array[Texture2D] = []
	
	for a in animation_names:
		var path := directory + a
		if !path.ends_with("/"):
			path += "/"
		var files := scan_for_files(path)
		
		var frame_range : Array[int] = []
		for f in files:
			frame_range.append(textures.size())
			textures.append(load(path + f))
		
		var anim := SpriteAnim.new()
		anim.name = a.trim_suffix(".png")
		anim.frames = frame_range
		group.animations.append(anim)
		print(anim.name)
	
	var packer := TexturePacker.new()
	var data := packer.pack_textures(textures)
	
	group.base_texture = data.texture
	group.sprite_frames = data.frames
	
	return group

func scan_for_directories(path: String) -> PackedStringArray:
	var paths := PackedStringArray()
	
	var dir := DirAccess.open(path)
	
	dir.list_dir_begin()
	var filename := dir.get_next()
	
	while filename != "":
		if dir.current_is_dir():
#			to_search.append(current_path + filename)
			paths.append(filename)

		filename = dir.get_next()

	dir.list_dir_end()
	return paths


func scan_for_files(path: String) -> PackedStringArray:
	var dir := DirAccess.open(path)
	var paths := PackedStringArray()
	
	dir.list_dir_begin()
	var filename := dir.get_next()
	
	while filename != "":
		if !dir.current_is_dir():
			if SUPPORTED.has(filename.get_extension()):
				paths.append(filename)

		filename = dir.get_next()

	dir.list_dir_end()
	return paths
