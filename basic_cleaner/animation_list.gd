extends Control

signal animation_clicked(index: int)
signal animation_toggled(index: int)

@export var animation_scene : PackedScene


func set_animations(anims : Array[String]) -> void:
	for c in get_children():
		c.queue_free()
	
	for i in anims.size():
		var animation := animation_scene.instantiate()
		animation.set_animation_name(anims[i])
		animation.clicked.connect(on_animation_clicked.bind(i))
		animation.visibility_toggled.connect(on_animation_toggled.bind(i))
		add_child(animation)


func on_animation_clicked(index: int) -> void:
	animation_clicked.emit(index)


func on_animation_toggled(index: int) -> void:
	animation_toggled.emit(index)

func toggle_animation(index: int, value: bool) -> void:
	get_child(index).set_visibility(value)
