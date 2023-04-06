@tool
extends MarginContainer


func _ready() -> void:
	$CreateNew.created_animation.connect(create_animation)


func create_animation() -> void:
	var project := AnimationProject.new()
	$AnimationOverview.set("project", project)
	
	$AnimationOverview.show()
	$CreateNew.hide()


func edit_animation(group: AnimationGroup) -> void:
	pass
