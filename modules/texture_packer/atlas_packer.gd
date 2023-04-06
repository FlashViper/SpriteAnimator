extends Node

const TexturePacker := preload("texture_packer.gd")
@onready var packer := TexturePacker.new()
@onready var file_system := preload("res://modules/project_manager/project_filesystem.gd").new()

func pack_folder(path: String) -> void:
	var files := file_system.get_files_from_dir(path)
	var end_paths : Array[String] = []
	for sub_dir in files:
		for f in files[sub_dir]:
			end_paths.append("%s/%s/%s" % [path, sub_dir, f])
