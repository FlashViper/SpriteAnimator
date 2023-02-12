extends Control

signal animation_clicked(index: int)

@export var animation_scene : PackedScene


func set_animations(anims : Array[String]) -> void:
	for i in get_child_count():
		get_child(i).queue_free()
	
	for i in anims.size():
		var animation := animation_scene.instantiate()
		animation.set_animation_name(anims[i])
		animation.clicked.connect(on_animation_clicked.bind(i))
		add_child(animation)


func on_animation_clicked(index: int) -> void:
	animation_clicked.emit(index)
