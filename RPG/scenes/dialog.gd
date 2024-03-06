extends Control

signal dialog_started
signal dialog_finished


var dialog = []
var current_dialog_idx = -1
var is_active = false

func _ready():
	$NinePatchRect.visible = false

func start(dialog_file):
	if is_active:
		return
	is_active = true

	dialog_started.emit()
	dialog = load_dialog(dialog_file)
	$NinePatchRect.visible = true
	next_script()
	
func load_dialog(dialog_file):
	var file = FileAccess.open(dialog_file, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func _input(event):
	if is_active and event.is_action_pressed("ui_accept"):
		next_script()

func next_script():
	current_dialog_idx += 1
	if current_dialog_idx >= len(dialog):
		is_active = false
		current_dialog_idx = -1
		$NinePatchRect.visible = false
		dialog_finished.emit()
		return
	$NinePatchRect/Name.text = dialog[current_dialog_idx]["name"]
	$NinePatchRect/Text.text = dialog[current_dialog_idx]["text"]	
