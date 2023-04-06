@tool
extends EditorPlugin

const PANEL := preload("gui/atlas_editor.tscn")
var dock_panel : Control

func _enter_tree() -> void:
	var main_screen := get_editor_interface().get_editor_main_screen()
	dock_panel = PANEL.instantiate()
	main_screen.add_child(dock_panel)
	dock_panel.hide()
#	add_control_to_bottom_panel(dock_panel, "Sprite Atlas")
#	make_bottom_panel_item_visible(dock_panel)


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	dock_panel.visible = visible


func _get_plugin_name() -> String:
	return "Atlas Editor"


func _edit(object) -> void:
	if object is AnimationGroup:
		dock_panel.edit_animation(object)


func _get_plugin_icon() -> Texture2D:
	return (
		get_editor_interface().
		get_base_control().
		get_theme_icon("AnimatedSprite2D", "EditorIcons")
	)


func _exit_tree() -> void:
	if dock_panel:
		var main_screen := (
			get_editor_interface().get_editor_main_screen()
		)
		
		main_screen.remove_child(dock_panel)
		dock_panel.queue_free()
