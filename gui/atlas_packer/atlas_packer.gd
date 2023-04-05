extends PanelContainer

const ProjectFiles := preload(
	"res://modules/project_manager/project_filesystem.gd"
)

const TexturePacker := preload(
	"res://modules/texture_packer/texture_packer.gd"
)

var textures : Array[Texture2D]

var filesystem := ProjectFiles.new()
var packer := TexturePacker.new()

func _ready() -> void:
	DisplayServer.window_set_drop_files_callback(
		add_textures_from_path
	)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_O:
				var dir := await FileSystem.request_directory()
				if dir != "":
					add_textures_from_directory(dir)

func add_textures_from_directory(dir: String) -> void:
	var paths : Array[String] = []
	var search := filesystem.get_files_from_dir(dir)
	
	for s in search:
		for p in search[s]:
			paths.append(dir + "/" + s + "/" + p)
	
	add_textures_from_path(paths)

func add_textures_from_path(paths: Array[String]) -> void:
	for p in paths:
		if filesystem.supports_image(p.get_extension()):
			var tex := filesystem.load_texture(p)
			textures.append(tex)
	pack()


func pack() -> void:
	var result := packer.pack_textures(textures)
	%Preview.texture = result["texture"]
	
