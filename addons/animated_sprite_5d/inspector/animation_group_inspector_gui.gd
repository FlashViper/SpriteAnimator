@tool
extends MarginContainer

@onready var display_container: CenterContainer = %DisplayContainer
@onready var display: Node2D = %Display
@onready var anim_names: OptionButton = %AnimNames


var animation_group : AnimationGroup :
	set(new):
		animation_group = new
		update_group()


func _ready() -> void:
	anim_names.item_selected.connect(update_anim)


func update_group() -> void:
	if animation_group == null:
		return
	
#	$VBoxContainer/Display.texture = animation_group.base_texture
	anim_names.clear()
	for a in animation_group.animations:
		anim_names.add_item(a.name)
	
	display.set_group(animation_group)


func update_anim(index: int) -> void:
	var anim_name : String = anim_names.get_item_text(index)
	var anim := animation_group.get_animation(anim_name)
	var max_size := Vector2()
	for f in anim.frames:
		var region := animation_group.sprite_frames[f].region
		max_size.x = maxf(max_size.x, region.size.x)
		max_size.y = maxf(max_size.y, region.size.y)
	
	var axis_index := display_container.size.min_axis_index()
	var scale_factor := display_container.size[axis_index] / max_size[axis_index]
	
	display.scale = Vector2.ONE * scale_factor
	display.play_animation(anim_name)
