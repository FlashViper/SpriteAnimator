extends PanelContainer

@export var list_item : PackedScene

@onready var list_root: Node = %ListRoot
@onready var preview_sprite : Node2D = %Preview
@onready var pack_preview: Node2D = %PackPreview

var project : AnimationProject
var current_anim : String

func _ready() -> void:
	if ProjectManager.current_project:
		project = ProjectManager.current_project
	else:
		project = AnimationProject.new()
		ProjectManager.current_project = project
	
	%Play.pressed.connect(on_play_pressed)
	%Loops.pressed.connect(on_toggle_loop)
	%Edit.pressed.connect(on_edit_pressed)
	%Properties.pressed.connect(on_properties_pressed)
	%Pack.pressed.connect(export)
	
	await get_tree().process_frame
	reload_animations()


func export() -> void:
	if project:
		var data := await project.export_project()
		%PackPreview.redraw(data)


func reload_animations() -> void:
	for c in list_root.get_children():
		c.queue_free()
	
	for a in project.animation_data:
		var item := list_item.instantiate()
		item.set_animation_name(a)
		item.selected.connect(change_animation.bind(a))
		item.visibility_toggled.connect(project.toggle_visible.bind(a))
		list_root.add_child(item)
	
	change_animation(project.animation_data.keys()[0])


func change_animation(anim_name : String) -> void:
	var anim : Dictionary = project.animation_data[anim_name]
	var frames : Array[Texture2D] = []
	for f in anim["frames"]:
		frames.append(project.raw_sprites[f])
	
	preview_sprite.set_animation(frames)
	preview_sprite.loops = anim.loops
	current_anim = anim_name


func on_play_pressed() -> void:
	preview_sprite.refresh_animation()


func on_toggle_loop() -> void:
	var loops := project.animation_data[current_anim]["loops"] as bool
	loops = !loops
	project.animation_data[current_anim]["loops"] = loops
	preview_sprite.loops = loops
	save()


func on_edit_pressed() -> void:
	pass


func on_properties_pressed() -> void:
	pass


func save() -> void:
	project.save_project(project.source_directory + "/animations.proj")
