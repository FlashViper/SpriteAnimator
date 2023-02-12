extends PanelContainer

const SpriteFrame := AnimationGroup.SpriteFrame
const SpriteAnimation := AnimationGroup.SpriteAnimation
const TexturePacker := preload("res://modules/texture_packer/texture_packer.gd")

#var raw_sprites : Array[Texture2D]
#var animation_data : Array[Dictionary] = []


func _ready() -> void:
	%LoadButton.pressed.connect(on_load_pressed)
	%SaveButton.pressed.connect(on_save_pressed)
	
	%ListRoot.animation_clicked.connect(preview)
	%ListRoot.animation_toggled.connect(toggle_animation)
	
	load_directory("res://test/player_split")


func toggle_animation(index: int) -> void:
	ProjectManager.animation_data[index]["visible"] = !ProjectManager.animation_data[index]["visible"]
	%ListRoot.toggle_animation(index, ProjectManager.get_animation(index)["visible"])


func on_load_pressed() -> void:
	FileSystem.set_current_directory("C:/users/ellio/Documents/Art")
	var path := await FileSystem.request_directory()
	
	if path != "":
		load_directory(path)


func preview(index: int) -> void:
	await get_tree().process_frame
	
	var anim := ProjectManager.get_animation(index)
	var textures : Array[Texture2D] = []
	
	for frame_index in anim["frames"]:
		textures.append(ProjectManager.get_frame(frame_index))
	
	%Display.set_animation(textures)
	%Display.update_scale()


func load_directory(path: String) -> void:
	var data : Dictionary = $Assembler.get_files_from_dir(path)
	ProjectManager.clear_data()
	
	for d in data:
		var filenames := data[d] as PackedStringArray
		var anim := {}
		
		if filenames.size() < 1:
			continue
		
		var frame_indexes : Array[int] = []
		for f in filenames:
			var tex : Texture2D = load_texture("%s/%s/%s" % [path, d, f])
			if !tex:
				continue
			frame_indexes.append(ProjectManager.raw_sprites.size())
			ProjectManager.add_frame(tex)
		
		anim["name"] = d
		anim["frames"] = frame_indexes
		anim["loops"] = true
		anim["visible"] = true
		ProjectManager.add_animation(anim)
	

	%ListRoot.set_animations(ProjectManager.get_name_list())
	preview(0)


func load_texture(path: String) -> Texture2D:
	var img := Image.load_from_file(path)
	var tex := ImageTexture.create_from_image(img)
	return tex


func on_save_pressed() -> void:
	const PATH := "res://test/RESULT.%s"
	
	var animations := ProjectManager.get_visible_animations()
	var visible_frames : Array[int] = []
	
	for a in animations:
		for f in a.frames:
			if !visible_frames.has(f):
				visible_frames.append(f)
	
	var textures : Array[Texture2D] = []
	for v in visible_frames:
		textures.append(ProjectManager.get_frame(v))
	
	var packer := TexturePacker.new()
	var data := packer.pack_textures(textures)
	
	var source_texture := data["texture"] as Texture2D
	var frames = data["frames"] as Array[SpriteFrame]
	
	var group := AnimationGroup.new()
	group.base_texture = source_texture
	group.animations = animations
	group.sprite_frames = frames
	
	var img := source_texture.get_image().save_png(PATH % "png")
	group.save_to_file(PATH % "sanim")
