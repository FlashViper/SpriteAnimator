extends Node


func _ready() -> void:
	$Button.pressed.connect(
		func():
			var filepath := await FileSystem.request_file()#["sanim"])
			
			if filepath != "":
				var group : AnimationGroup = load(filepath)
				$AnimatedSprite5D.set_group(group)
	)
