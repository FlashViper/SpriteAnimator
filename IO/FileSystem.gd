extends FileDialog

signal finished(path: String)

func _ready() -> void:
	file_selected.connect(on_path_selected)
	dir_selected.connect(on_path_selected)
	canceled.connect(on_path_selected.bind(""))

func on_path_selected(file: String) -> void: 
	finished.emit(file)

func request_file(extensions := PackedStringArray()) -> String:
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	filters = extensions
	
	popup_centered(Vector2(1080, 600))
	return await finished


func request_directory() -> String:
	file_mode = FileDialog.FILE_MODE_OPEN_DIR
	
	popup_centered(Vector2(1080, 600))
	return await finished

func request_save(extensions := PackedStringArray()) -> String:
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	filters = extensions
	
	popup_centered(Vector2(1080, 600))
	return await finished
