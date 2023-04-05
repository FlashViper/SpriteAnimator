extends EditorInspectorPlugin

const INSPECTOR_GUI_SCENE := preload(
	"inspector/animation_group_inspector.tscn"

)
var inspector_gui : Control

func _can_handle(object: Object) -> bool:
	return (
		object is AnimationGroup or 
		object is AnimatedSprite5D
	)


func _parse_begin(object: Object) -> void:
	if inspector_gui:
		if is_instance_valid(inspector_gui):
			if !inspector_gui.is_queued_for_deletion():
				inspector_gui.queue_free()
	
	var group : AnimationGroup
	if object is AnimationGroup:
		group = object
	elif object is AnimatedSprite5D:
		group = object.animation_group
	else:
		return
	
	inspector_gui = INSPECTOR_GUI_SCENE.instantiate()
	inspector_gui.set_deferred("animation_group", object)
	add_custom_control(inspector_gui)

func _parse_property(
			object: Object, 
			type: Variant.Type, 
			name: String, 
			hint_type: PropertyHint, 
			hint_string: String, 
			usage_flags: PropertyUsageFlags, 
			wide: bool
		) -> bool:
	
	return false
