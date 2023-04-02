extends PanelContainer

@export var list_item : PackedScene

@onready var list_root: Node = %ListRoot
@onready var preview_sprite : Node2D = %Preview

var project : AnimationProject


func _ready() -> void:
	if ProjectManager.current_project:
		project = ProjectManager.current_project
	else:
		project = AnimationProject.new()
		ProjectManager.current_project = project
	
#	print(preload("res://RESULT.sanim").sprite_frames)
	%Play.pressed.connect(on_play_pressed)
	%Loops.pressed.connect(on_toggle_loop)
	%Edit.pressed.connect(on_edit_pressed)
	%Properties.pressed.connect(on_properties_pressed)
	%Pack.pressed.connect(export)
	
	await get_tree().process_frame
	reload_animations()


func export() -> void:
	if project:
		project.export_project()


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


func on_play_pressed() -> void:
	pass


func on_toggle_loop() -> void:
	pass


func on_edit_pressed() -> void:
	pass


func on_properties_pressed() -> void:
	pass
