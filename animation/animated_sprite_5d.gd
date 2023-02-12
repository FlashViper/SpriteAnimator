extends Node2D

const ANIMATION := preload("./animation.gd")

@export var fps := 12
@onready var frame_duration := 1.0 / fps

var current_anim : ANIMATION
var progress : float

#func _ready() -> void:
#	set_process(false)

func play_animation(anim: ANIMATION) -> void:
	current_anim = anim
	progress = 0

func _process(delta: float) -> void:
	progress += delta
	queue_redraw()
@onready var thing2 := [
	load("res://test/cast/player_cast_0000.png"), 
	load("res://test/cast/player_cast_0001.png"), 
	load("res://test/cast/player_cast_0002.png"), 
	load("res://test/cast/player_cast_0003.png"), 
	load("res://test/cast/player_cast_0004.png"), 
	load("res://test/cast/player_cast_0005.png"), 
	load("res://test/cast/player_cast_0006.png"),
]
var thing : Array[Dictionary]
var source : Texture2D

#JANK, DO NOT USE UNDER ANY CIRCUMSTANCES, THIS WAS NEVER MENT TO BE PRODUCTION READY
func _ready() -> void:
	var file := FileAccess.open("res://test/player.tpsheet", FileAccess.READ)
	var data := JSON.parse_string(file.get_as_text()) as Dictionary
	var frames : Array[Dictionary] = []
	source = load("res://test/" + data.meta.image)
	thing = []
	
	for f in data.frames:
		var to_modify := (data.frames[f] as Dictionary).duplicate()
		to_modify["path"] = f
		frames.append(to_modify)
	
	frames.sort_custom(func(a: Dictionary,b: Dictionary): return a.path < b.path)
	for f in frames:
		var region := Rect2(f.frame.x, f.frame.y, f.frame.w, f.frame.h)
		var pivot := Vector2(f.pivot.x, f.pivot.y)
		var original_poition := Vector2(f.spriteSourceSize.x, f.spriteSourceSize.y)
		var original_size := Vector2(f.sourceSize.w, f.sourceSize.h)
		
		var final := {}
		
		var pivot_adjusted := pivot * original_size# + (region.position - original_poition)
		
		final.src_size = Rect2(f.spriteSourceSize.x, f.spriteSourceSize.y, f.spriteSourceSize.w, f.spriteSourceSize.h)
		final.region = region
		final.pivot = pivot_adjusted
		thing.append(final)

func _draw() -> void:
#	if !current_anim:
#		return
	
	for t in thing:
		draw_rect(t.region, Color.MEDIUM_VIOLET_RED, false, 3.0)
		draw_rect(t.src_size, Color.ORANGE_RED, false, 3.0)
	
	var current_frame := int(wrapf(progress * fps, 0, 6.0))
	var region := thing[current_frame].region as Rect2
	draw_texture_rect_region(source, Rect2(-thing[current_frame].pivot, region.size), region)# -thing[current_frame].pivot)
	draw_texture(thing2[current_frame], Vector2.DOWN * 300)
