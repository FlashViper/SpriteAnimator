extends Node

@onready var list := %AnimationList
var list_item_scene := preload("res://basic_prototype/scenes/animation_segment.tscn")
var animations : Array[String]

func _ready() -> void:
	var animation = $AnimationBuilder.create_from_dir("res://test/player_split/")
	var img := animation.base_texture.get_image() as Image
#	img.save_png("res://test/test_loader.png")
	
	animation.save_to_file("res://test/test_anim.anim")
	
	$Sprite.set_group(animation)
	$Sprite.play("021.WallSlide")
	
	animations = []
	
	for a in animation.animations:
		var list_item := list_item_scene.instantiate()
		list_item.get_node("HBoxContainer/Name").text = a.name
		list_item.gui_input.connect(on_list_item_input.bind(animations.size()))
		list.add_child(list_item)
		animations.append(a.name)


func on_list_item_input(event: InputEvent, index:int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.double_click:
				$Sprite.play(animations[index])
