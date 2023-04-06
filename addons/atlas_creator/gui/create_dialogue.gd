@tool
extends PanelContainer

signal created_atlas
signal created_animation
signal created


@onready var create_animation: Button = %CreateAnimation
@onready var create_atlas: Button = %CreateAtlas


func _ready() -> void:
	create_animation.pressed.connect(on_create_animation)
	create_atlas.pressed.connect(on_create_atlas)


func on_create_animation() -> void:
	created_animation.emit()


func on_create_atlas() -> void:
	created_atlas.emit()
