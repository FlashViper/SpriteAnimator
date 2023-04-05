class_name SpriteAnimation 
extends Resource

@export var name : String
@export var frames : Array[int]
@export var loops : bool


func size() -> int:
	return (frames.size() if frames != null else 0)
