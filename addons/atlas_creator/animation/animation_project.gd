class_name AnimationProject
extends Resource

const PROJECT_FILE := "animations.proj"

const TexturePacker := preload(
	"res://modules/texture_packer/texture_packer.gd"
)
#const SpriteAnimation := AnimationGroup.SpriteAnimation
#const SpriteFrame := AnimationGroup.SpriteFrame

const ProjectFiles := preload(
	"res://modules/project_manager/project_filesystem.gd"
)

signal loaded_new_project
signal progress_changed(new: float, message: String)

@export var source_directory : String
@export var export_file_name : String = "RESULT"
@export var export_path : String = "res://"

var raw_sprites := {}
@export var animation_data : Dictionary = {}
var filesystem := ProjectFiles.new()

# Loading Stuff
var current_progress := 0.0
var current_progress_message := ""


func get_name_list() -> Array[String]:
	var names : Array[String] = []
	for a in animation_data:
		names.append(a.name)
	return names


func toggle_visible(anim_name: String) -> bool:
	var current := animation_data[anim_name].visible as bool
	animation_data[anim_name].visible = !current
	return !current


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
	ResourceSaver.save(
		self, 
		path + ".tres", 
		ResourceSaver.FLAG_OMIT_EDITOR_PROPERTIES
	)
	return
	
	var data := {
		"export_path": export_path,
		"textures": raw_sprites.keys(),
		"animation_data": animation_data,
	}
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


func load_project(path: String) -> void:
	if !DirAccess.dir_exists_absolute(path):
		return
	
	print("Started loading ", path)
	
	var file_path := "%s/%s" % [path, PROJECT_FILE]
	current_progress = 0.0
	current_progress_message = ""
	
	source_directory = path
	raw_sprites = {}
	animation_data = {}
	
	if FileAccess.file_exists(file_path):
		print("Loading project file")
		
		var f := FileAccess.open(file_path, FileAccess.READ)
		var data : Dictionary = JSON.parse_string(f.get_as_text())
		
		var progress_per_texture : float = 1.0 / data.textures.size()
		for tex in data.textures:
			current_progress_message = "Loading %s" % tex
			progress_changed.emit(
				current_progress,
				current_progress_message
			)
			
			raw_sprites[tex] = filesystem.load_texture(path + "/" + tex)
			current_progress += progress_per_texture
		
		
		export_path = data["export_path"]
		animation_data = data["animation_data"]
#		for anim_name in data.animation_data:
#			var frames : Array[int] = []
#			for frame_path in data.animation_data[anim_name]:
#				frames.append(raw_sprites[])
#			var anim := {
#				"frames": frames,
#				"name": anim_name,
#				"loops": data.animation_data[anim_name]["loops"],
#				"visible": data.animation_data[anim_name]["visible"],
#			}
#
#			animation_data[anim_name] = anim
		
	
	reload_project()
	save_project(file_path)
	loaded_new_project.emit()
	
	# allows to work with multithreading
#	await get_tree().process_frame
#	await get_tree().process_frame


func reload_project(reset_data := false) -> void:
	print("Reloading Directory")
	
	var data := filesystem.get_files_from_dir(source_directory)
	raw_sprites = {}
	if reset_data:
		animation_data = {}
	
	current_progress = 0
	current_progress_message = ""
	
	for anim_name in data:
		print("Searching ", anim_name)
		current_progress_message = "Searching %s" % anim_name
		progress_changed.emit(
			current_progress,
			current_progress_message
		)
		
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
		
		current_progress += 1.0 / data.size()


func load_frames(
			anim_name: String, 
			filenames: PackedStringArray
			) -> Array[String]:
	var frames : Array[String] = []
	
	for f in filenames:
		var tex_id := "%s/%s" % [anim_name, f]
		var tex := filesystem.load_texture("%s/%s/%s" % [
			source_directory, 
			anim_name, 
			f
		])
		
		if !tex:
			continue
		
		frames.append(tex_id)
		raw_sprites[tex_id] = tex
	
	return frames


func export_project(path := "") -> Dictionary:
	if path != "":
		export_path = path
	
	if export_path == "":
		export_path = await FileSystem.request_directory()
	
	var visible_animations := []
	for anim in animation_data:
		if animation_data[anim].visible:
			visible_animations.append(animation_data[anim])
	
	var required_textures : Array[String] = []
	for anim in visible_animations:
		for f in anim.frames:
			required_textures.append(f)
	
	var textures : Array[Texture2D] = []
	var texture_mapping := {}
	
	for tex_path in required_textures:
		if texture_mapping.has(tex_path):
			continue
		
		texture_mapping[tex_path] = textures.size()
		textures.append(raw_sprites[tex_path])
	
	var group := AnimationGroup.new()
	group.animations = []
	
	for anim in visible_animations:
		var animation := SpriteAnimation.new()
		animation.name = anim["name"]
		animation.loops = anim["loops"]
		
		animation.frames = []
		for f in anim.frames:
			animation.frames.append(texture_mapping[f])
		
		group.animations.append(animation)
	
	var packer := TexturePacker.new()
	var pack_data : Dictionary = packer.pack_textures(textures)
	
	group.sprite_frames = []
	for f in pack_data["frames"]:
		var frame := SpriteFrame.new()
		frame.region = f["atlas_region"]
		frame.pivot = f["pivot"]
		group.sprite_frames.append(frame) 
	
	
	if pack_data.is_empty():
		return {}
	
	var export_path_template := "%s/%s.%s" % [
		export_path, 
		export_file_name, 
		"%s"
	]
	pack_data.texture.get_image().save_png(export_path_template % "png")
	
	var atlas_data := group.to_dictionary()
	atlas_data.texture_path = export_path_template % "png"

	var file := FileAccess.open(
		export_path_template % "sanim", 
		FileAccess.WRITE
	)
	
	file.store_string(JSON.stringify(atlas_data, "\t", false))
	return pack_data
