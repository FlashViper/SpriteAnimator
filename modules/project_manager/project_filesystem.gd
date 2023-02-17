extends RefCounted

const PROJECT_LIST_PATH := "user://recent_projects.txt"

var extensions : Array[String] = [
	"png", 
	"jpeg", 
	"jpg",
	"webp",
]


## { ANIMATION_NAME : String --> TEXTURES : PackedStringArray }
func get_files_from_dir(path: String) -> Dictionary:
	var result := {}
	var open : Array[String] = [""]
	
	while open.size() > 0:
		var current_path : String = open.pop_front()
		var files := PackedStringArray()
		
		var dir := DirAccess.open("%s/%s" % [path, current_path])
		dir.list_dir_begin()
		
		var filename := dir.get_next()
		while filename != "":
			if dir.current_is_dir():
				open.append(filename)
			else:
				if extensions.has(filename.get_extension()):
					files.append(filename)
				
			filename = dir.get_next()
		
		result[current_path] = files
		dir.list_dir_end()
	
	return result


func load_texture(path: String) -> Texture2D:
	var img := Image.load_from_file(path)
	var tex := ImageTexture.create_from_image(img)
	return tex


func get_recent_paths() -> Array[String]:
	if FileAccess.file_exists(PROJECT_LIST_PATH):
		var lines := FileAccess.get_file_as_string(PROJECT_LIST_PATH).split("\n", false)
		var remapped : Array[String] = []
		for l in lines:
			remapped.append(l)
		return remapped
	else:
		return []


func add_recent_path(new: String) -> void:
	var new_paths := get_recent_paths()
	if new_paths.has(new):
		var idx := new_paths.find(new)
		new_paths.remove_at(idx)
	
	new_paths.insert(0, new)
	
	var f := FileAccess.open(PROJECT_LIST_PATH, FileAccess.WRITE)
	for n in new_paths:
		if n:
			f.store_line(n)
