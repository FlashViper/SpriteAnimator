extends PanelContainer

const ProjectFiles := preload("res://modules/project_manager/project_filesystem.gd")

@export var list_item_scene : PackedScene

@onready var list_root := %ProjectList

func _ready() -> void:
	reload_project_list()


func reload_project_list() -> void:
	for c in list_root.get_children():
		c.queue_free()
	
	var filesystem := ProjectFiles.new()
	var paths := filesystem.get_recent_paths()
	
	var add_item := list_item_scene.instantiate()
	add_item.get_node("%ProjectLabel").text = "+ Load New Directory"
	add_item.double_clicked.connect(on_load_new_pressed)
	list_root.add_child(add_item)
	
	for p in paths:
		var item := list_item_scene.instantiate()
		item.get_node("%ProjectLabel").text = p
		item.double_clicked.connect(load_directory.bind(p))
		list_root.add_child(item)


func on_load_new_pressed() -> void:
	var directory := await FileSystem.request_directory()
	
	if directory != "":
		load_directory(directory)


func load_directory(path: String) -> void:
	ProjectManager.load_project(path)
	
	var filesystem := ProjectFiles.new()
	filesystem.add_recent_path(path)
	
	get_tree().change_scene_to_file("res://basic_cleaner/animation_manager.tscn")


func preview_project() -> void:
	pass
