extends PanelContainer

const ProjectFiles := preload("res://modules/project_manager/project_filesystem.gd")

@export var animation_overview_scene : PackedScene
@export var list_item_scene : PackedScene

@onready var list_root := %ProjectList
@onready var thread := Thread.new()

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

"res://test/swollow_knite/animations.proj.tres.tres"
func load_directory(path: String) -> void:
	var project : AnimationProject = ResourceLoader.load(path + "/animations.proj.tres")
	if project == null:
		project = AnimationProject.new()
		project.source_directory = path
	var filesystem = ProjectFiles.new()
	filesystem.add_recent_path(path)
	project.reload_project()
	project.save_project(path + "/animations.proj")
#	var project := AnimationProject.new()
#	thread.start(project.load_project.bind(path))
##	ProjectManager.load_project(path)
#
#	var filesystem := ProjectFiles.new()
#	filesystem.add_recent_path(path)
#
#	%ProgressBar.show()
#	%ProgressBar.initialize()
#	project.progress_changed.connect(%ProgressBar.update_progress)
#	await project.loaded_new_project
#	thread.wait_to_finish.call_deferred()
#	%ProgressBar.hide()
	
	ProjectManager.current_project = project
#	project.progress_changed.disconnect(%ProgressBar.update_progress)
	get_tree().change_scene_to_packed(animation_overview_scene)


func preview_project() -> void:
	pass
