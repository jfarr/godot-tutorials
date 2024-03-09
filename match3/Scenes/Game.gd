extends Node

func _ready():
	$HUD/GameOverText.visible = false
	$HUD/LevelCompleteText.visible = false
	$HUD/ContinueButton.visible = false

func _on_grid_game_over():
	$HUD/GameOverText.visible = true

func _on_grid_level_complete():
	$HUD/LevelCompleteText.visible = true
	$HUD/ContinueButton.visible = true


func _on_continue_button_pressed():
	$HUD/LevelCompleteText.visible = false
	$HUD/ContinueButton.visible = false
	$Grid.next_level()

