extends Node

const PROJECT_FILE := "animations.proj"
const SpriteAnimation := AnimationGroup.SpriteAnimation
const SpriteFrame := AnimationGroup.SpriteFrame

const ProjectFiles := preload("project_filesystem.gd")

var source_directory : String
var export_path : String

var raw_sprites := {}
var animation_data : Dictionary = {}
var filesystem : ProjectFiles


func _ready() -> void:
	filesystem = ProjectFiles.new()
	load_project("C:/Users/ellio/Documents/Godot/AnimationGame/Art/Animations")


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


func save_project(path: String) -> void:
	# TODO: Save data here
	var data := {
		"export_path": export_path,
		"textures": raw_sprites,
		"animation_data": animation_data,
	}
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


func load_project(path: String) -> void:
	if !DirAccess.dir_exists_absolute(path):
		return
	
	var file_path := "%s/%s" % [path, PROJECT_FILE]
	
	source_directory = path
	raw_sprites = {}
	animation_data = {}
	
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		var data : Dictionary = JSON.parse_string(f.get_as_text())
		
		export_path = data.export_path
		raw_sprites = data.textures
		animation_data = data.animation_data
		
	
	reload_project()
	save_project(file_path)


func reload_project(reset_data := false) -> void:
	var data := filesystem.get_files_from_dir(source_directory)
	raw_sprites = {}
	animation_data = {}
	
	for anim_name in data:
		var filenames := data[anim_name] as PackedStringArray
		if filenames.size() < 1:
			continue
		
		var frames := load_frames(anim_name, filenames)
		
		if animation_data.has(anim_name):
			animation_data[anim_name].frames = frames
		else:
			animation_data[anim_name] = {
				"frames":frames,
				"name": anim_name,
				"loops": true,
				"visible": true,
			}


func load_frames(anim_name: String, filenames: PackedStringArray) -> Array[String]:
	var frames : Array[String] = []
	
	for f in filenames:
		var tex_id := "%s/%s" % [anim_name, f]
		var tex := filesystem.load_texture("%s/%s/%s" % [source_directory, anim_name, f])
		
		if !tex:
			continue
		
		frames.append(tex_id)
		raw_sprites[tex_id] = tex
	
	return frames


func export_project(path := "") -> void:
	if path != "":
		export_path = path
	
