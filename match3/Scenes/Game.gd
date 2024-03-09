extends Node

func _ready():
	$GameOver.visible = false


func _on_grid_game_over():
	$GameOver.visible = true
