extends Resource

@export var layer_name := "New Layer"

var frames := {}

func _get_frame(frame: int) -> Texture2D:
	var tex : Texture2D = null
	var current_frame := frame
	
	while current_frame >= 0:
		if frames.has(frame):
			return frames[frame]
	
	return tex

