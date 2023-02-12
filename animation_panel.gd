extends PanelContainer

@onready var background := %Background
@onready var sprite_canvas := %Sprite_Draw

func _ready() -> void:
	var input := %Input_Grabber
	input.drag_inputted.connect(on_drag)
	
	get_window().files_dropped.connect(on_files_submitted)

func on_drag(delta: Vector2) -> void:
	background.offset(delta)
	sprite_canvas.offset(delta)

func on_files_submitted(files: PackedStringArray) -> void:
	var textures : Array[Texture2D] = []
	
	for f in files:
		var img := Image.new()
		var err := img.load(f)
		
		if err == OK:
			textures.append(ImageTexture.create_from_image(img))
	
	sprite_canvas.set_textures(textures)
