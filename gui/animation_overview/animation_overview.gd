extends PanelContainer

@export var list_item : PackedScene

@onready var list_root: Node = %ListRoot
@onready var preview_sprite : Node2D = %Preview


func _ready() -> void:
	%Play.pressed.connect(on_play_pressed)
	%Loops.pressed.connect(on_toggle_loop)
	%Edit.pressed.connect(on_edit_pressed)
	%Properties.pressed.connect(on_properties_pressed)
	
	await get_tree().process_frame
	reload_animations()


func reload_animations() -> void:
	for c in list_root.get_children():
		c.queue_free()
	
	for a in ProjectManager.animation_data:
		var item := list_item.instantiate()
		item.set_animation_name(a)
		item.selected.connect(change_animation.bind(a))
		list_root.add_child(item)
	
	change_animation(ProjectManager.animation_data.keys()[0])


func change_animation(anim_name : String) -> void:
	var anim : Dictionary = ProjectManager.animation_data[anim_name]
	var frames : Array[Texture2D] = []
	for f in anim["frames"]:
		frames.append(ProjectManager.raw_sprites[f])
	
	preview_sprite.set_animation(frames)


func on_play_pressed() -> void:
	pass


func on_toggle_loop() -> void:
	pass


func on_edit_pressed() -> void:
	pass


func on_properties_pressed() -> void:
	pass
