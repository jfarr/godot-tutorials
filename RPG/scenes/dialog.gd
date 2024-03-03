extends Control

signal dialog_finished

@export_file("*.json") var dialog_file

var dialog = []
var current_dialog_idx = -1
var is_active = false

func _ready():
	$NinePatchRect.visible = false

func start():
	if is_active:
		return
	is_active = true

	dialog = load_dialog()
	$NinePatchRect.visible = true
	next_script()
	
func load_dialog():
	var file = FileAccess.open("res://assets/dialog/worker_dialog1.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func _input(event):
	if is_active and event.is_action_pressed("ui_accept"):
		next_script()

func next_script():
	current_dialog_idx += 1
	if current_dialog_idx >= len(dialog):
		is_active = false
		$NinePatchRect.visible = false
		dialog_finished.emit()
		return
	$NinePatchRect/Name.text = dialog[current_dialog_idx]["name"]
	$NinePatchRect/Text.text = dialog[current_dialog_idx]["text"]	
