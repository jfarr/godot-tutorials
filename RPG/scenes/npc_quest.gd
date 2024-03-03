extends Control

signal quest_menu_closed

var quest1_active = false
var quest1_complete = false
var stick = 0

func _process(delta):
	if quest1_active:
		if stick == 3:
			quest1_active = false
			quest1_complete = true
			play_finish_quest()

func next_quest():
	if !quest1_complete:
		quest1_chat()
	else:
		$NoQuest.visible = true
		await get_tree().create_timer(3).timeout
		$NoQuest.visible = false

func quest1_chat():
	$Quest1.visible = true

func _on_yes_button_1_pressed():
	$Quest1.visible = false
	quest1_active = true
	quest_menu_closed.emit()

func _on_no_button_1_pressed():
	$Quest1.visible = false
	quest_menu_closed.emit()

func stick_collected():
	stick += 1

func play_finish_quest():
	$FinishedQuest.visible = true
	await get_tree().create_timer(3).timeout
	$FinishedQuest.visible = false
