@tool
extends EditorPlugin


var importer

func _enter_tree() -> void:
	importer = preload("importer_animation_group.gd").new()
	add_import_plugin(importer)
	
#	add_custom_type()


func _exit_tree() -> void:
	if importer:
		remove_import_plugin(importer)
		importer = null
