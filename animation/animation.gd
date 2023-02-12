extends Resource

const SPRITE_LAYER := preload("./animation_layer.gd")

@export var loops := false

var sprite_layers : Array[SPRITE_LAYER] = []
var collision : Array = []
var flags : Array[String]

func get_length() -> int:
	return 0

func get_textures_at_frame(frame: int) -> void:
	pass
