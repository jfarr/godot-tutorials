extends Node2D

func _ready():
	$Game.visible = false

func _on_new_game_button_pressed():
	$MenuPanel.visible = false
	$Game.visible = true
	$Game.new_game()

func _on_continue_button_pressed():
	$MenuPanel.visible = false
	$Game.visible = true
	$Game.continue_game()
