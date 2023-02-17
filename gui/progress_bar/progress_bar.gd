extends PanelContainer

@onready var progress: ProgressBar = %Progress
@onready var statement: Label = %Statement


func initialize() -> void:
	statement.text = ""
	progress.value = 0


func update_progress(new_value : float, new_statement := "") -> void:
	statement.text = new_statement
	var t := create_tween().tween_property(
		progress,
		"value",
		new_value,
		0.15
	)
	
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
