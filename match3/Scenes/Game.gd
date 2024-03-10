extends Node

func _ready():
	$HUD/GameOverText.visible = false
	$HUD/LevelCompleteText.visible = false
	$HUD/ContinueButton.visible = false
	$HUD/UndoButton.disabled = true
	$HUD/LevelText.text = "[center]Level 1[/center]"
	$Grid.next_level()

func _on_grid_game_over():
	$HUD/GameOverText.visible = true

func _on_grid_level_complete():
	$HUD/LevelCompleteText.visible = true
	$HUD/ContinueButton.visible = true
	$HUD/UndoButton.disabled = true

func _on_continue_button_pressed():
	$HUD/LevelCompleteText.visible = false
	$HUD/ContinueButton.visible = false
	$Grid.next_level()
	$HUD/LevelText.text = "[center]Level %d[/center]" % $Grid.level

func _on_undo_button_pressed():
	$Grid.undo_move()

func _on_grid_moved():
	$HUD/UndoButton.disabled = $Grid.move_history.size() == 0
