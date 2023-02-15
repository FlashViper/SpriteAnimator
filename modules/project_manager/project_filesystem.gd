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
		var current_path := open.pop_front()
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
