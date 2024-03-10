extends Node

var max_level = 0

func _ready():
	$HUD/GameOverText.visible = false
	$HUD/LevelCompleteText.visible = false
	$HUD/ContinueButton.visible = false
	$HUD/UndoButton.disabled = true
	#load_game()
	#$Grid.level = max_level
	#$HUD/LevelText.text = "[center]Level %s[/center]" % ($Grid.level + 1)
	#$Grid.next_level()

func new_game():
	$HUD/LevelText.text = "[center]Level %s[/center]" % ($Grid.level + 1)
	$Grid.next_level()

func continue_game():
	load_game()
	$Grid.level = max_level
	$HUD/LevelText.text = "[center]Level %s[/center]" % ($Grid.level + 1)
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
	save_game()
	$Grid.next_level()
	$HUD/LevelText.text = "[center]Level %d[/center]" % $Grid.level

func _on_undo_button_pressed():
	$Grid.undo_move()

func _on_grid_moved():
	$HUD/UndoButton.disabled = $Grid.move_history.size() == 0

func save_game():
	var game_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var data = {"level": $Grid.level}
	var json_string = JSON.stringify(data)
	game_file.store_line(json_string)

func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var game_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = game_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
		var data = json.get_data()
		max_level = data["level"]
