@tool
extends EditorPlugin

const PANEL := preload("res://gui/animation_overview/animation_overview.tscn")
var dock_panel : Control

func _enter_tree() -> void:
	dock_panel = PANEL.instantiate()
	add_control_to_bottom_panel(dock_panel, "Sprite Atlas")
	
	make_bottom_panel_item_visible(dock_panel)


func _exit_tree() -> void:
	if dock_panel:
		remove_control_from_bottom_panel(dock_panel)
