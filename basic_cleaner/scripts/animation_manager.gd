extends PanelContainer

const AnimationGroup := preload("res://IO/animation_group.gd")
const SpriteFrame := AnimationGroup.SpriteFrame
const SpriteAnimation := AnimationGroup.SpriteAnimation


var raw_sprites : Array[Texture2D]
var animation_data : Array[Dictionary] = []


func _ready() -> void:
	%LoadButton.pressed.connect(on_load_pressed)
	%SaveButton.pressed.connect(on_save_pressed)
	load_directory("res://test/variety")



func on_load_pressed() -> void:
	var path := await FileSystem.request_directory()
	
	if path != "":
		load_directory(path)


func preview(index: int) -> void:
	await get_tree().process_frame
	
	var anim := animation_data[index]
	var textures : Array[Texture2D] = []
	
	for frame_index in anim["frames"]:
		textures.append(raw_sprites[frame_index])
	
	%Display.set_animation(textures)
	%Display.update_scale()


func load_directory(path: String) -> void:
	var data : Dictionary = $Assembler.get_files_from_dir(path)
	raw_sprites = []
	
	for d in data:
		var filenames := data[d] as PackedStringArray
		var anim := {}
		
		if filenames.size() < 1:
			continue
		
		var frame_indexes : Array[int] = []
		for f in filenames:
			var tex : Texture2D = load("%s/%s/%s" % [path, d, f])
			if !tex:
				continue
			frame_indexes.append(raw_sprites.size())
			raw_sprites.append(tex)
		
		anim["name"] = d
		anim["frames"] = frame_indexes
		anim["loops"] = true
		animation_data.append(anim)
	
	var names : Array[String] = []
	for a in animation_data:
		names.append(a.name)
	%ListRoot.set_animations(names)
	%ListRoot.animation_clicked.connect(preview)
	
	preview(0)


func on_save_pressed() -> void:
	var path := "res://test/RESULT.%s"
	var packer := preload("res://IO/texture_packer.gd").new()
	var data := packer.pack_textures(raw_sprites)
	
	var source_texture := data["texture"] as Texture2D
	var frames = data["frames"] as Array[SpriteFrame]
	
	var animations : Array[SpriteAnimation] = []
	for a in animation_data:
		var anim := SpriteAnimation.new()
		anim.name = a.name
		anim.frames = a.frames
		anim.loops = a.loops
		animations.append(anim)
	
	
	var group := AnimationGroup.new()
	group.base_texture = source_texture
	group.animations = animations
	group.sprite_frames = frames
	
	var img := source_texture.get_image().save_png(path % "png")
	group.save_to_file(path % "sanim")
