@tool
extends Container

@export var offset : Vector2 :
	set(new):
		offset = new
		queue_sort()
@export_flags("Horizontal", "Vertical") var direction_flags := 0b11

func _init() -> void:
	clip_children = CLIP_CHILDREN_AND_DRAW

func _ready() -> void:
	sort_children.connect(sort)

func sort() -> void:
	for i in get_child_count():
		if get_child(i) is Control:
			var c := get_child(i) as Control
			c.position = offset
			c.size = size

func get_drag_vector() -> Vector2:
	return Vector2((direction_flags & 0b1), (direction_flags & 0b10) >> 1)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) > 0:
			offset += event.relative * get_drag_vector()
			accept_event()
