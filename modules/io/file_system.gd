extends FileDialog

signal finished(path: String)

@export var minimup_size := Vector2(1920, 1080) * 0.8

func _ready() -> void:
	file_selected.connect(on_path_selected)
	dir_selected.connect(on_path_selected)
	canceled.connect(on_path_selected.bind(""))


func on_path_selected(file: String) -> void: 
	finished.emit(file)


func request_file(extensions := PackedStringArray()) -> String:
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	filters = extensions
	
	popup_centered(minimup_size)
	return await finished


func request_directory() -> String:
	file_mode = FileDialog.FILE_MODE_OPEN_DIR
	
	popup_centered(minimup_size)
	return await finished

func request_save_file(extensions := PackedStringArray()) -> String:
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	filters = extensions
	
	popup_centered(minimup_size)
	return await finished


func set_current_directory(path: String) -> void:
	current_dir = path
