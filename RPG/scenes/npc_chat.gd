extends Node2D

@export_file("*.json") var dialog_file

var player_in_chat_area = false

func process(_delta):
	if player_in_chat_area and Input.is_action_just_pressed("ui_use"):
		$Dialog.start(dialog_file)

func _on_chat_area_body_entered(_body):
	player_in_chat_area = true

func _on_chat_area_body_exited(_body):
	player_in_chat_area = false
