@tool
extends EditorPlugin


var importer
var inspector

func _enter_tree() -> void:
	importer = preload("importer_animation_group.gd").new()
	inspector = preload("inspector_animation_group.gd").new()
	add_import_plugin(importer)
	add_inspector_plugin(inspector)
	
#	add_custom_type()


func _exit_tree() -> void:
	if importer:
		remove_import_plugin(importer)
		importer = null
	
	if inspector:
		remove_inspector_plugin(inspector)
		inspector = null
