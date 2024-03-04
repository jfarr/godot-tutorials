extends Control

signal quest_menu_closed

var quest = null
var quest1_active = false
var quest1_complete = false

func show_quest(npc, quest):
	self.quest = quest
	$Quest/Name.text = npc.npc_name
	$Quest/Text.text = quest.text
	$Quest.visible = true

func show_no_quest():
	$NoQuest.visible = true
	await get_tree().create_timer(3).timeout
	$NoQuest.visible = false

func _on_yes_button_1_pressed():
	$Quest.visible = false
	if quest:
		quest.start()
	#quest1_active = true
	quest_menu_closed.emit()

func _on_no_button_1_pressed():
	$Quest.visible = false
	quest_menu_closed.emit()

func play_finish_quest():
	$FinishedQuest.visible = true
	await get_tree().create_timer(3).timeout
	$FinishedQuest.visible = false
