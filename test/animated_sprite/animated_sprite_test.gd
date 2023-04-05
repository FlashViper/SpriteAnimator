extends Node


func _ready() -> void:
	$Button.pressed.connect(
		func():
			var filepath := await FileSystem.request_file()#["sanim"])
			
			if filepath != "":
				var group : AnimationGroup = load(filepath)
				$AnimatedSprite5D.set_group(group)
	)
	
	$LineEdit.text_submitted.connect(
		func(anim_name: String):
			$AnimatedSprite5D.play_animation(anim_name)
			$AnimatedSpriteDebug.debug_animation(anim_name)
	)
