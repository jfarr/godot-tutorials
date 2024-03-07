extends Control

class_name NPCQuest

signal quest_menu_opened
signal quest_menu_closed

var player = null
var quest = null

func show_quest(player, npc, quest):
	quest_menu_opened.emit()
	self.player = player
	self.quest = quest
	$Quest/Name.text = npc.npc_name
	$Quest/Text.text = quest.text
	$Quest.visible = true

func show_no_quest(npc):
	quest_menu_opened.emit()
	$NoQuest/Name.text = npc.npc_name
	$NoQuest.visible = true
	await get_tree().create_timer(3).timeout
	$NoQuest.visible = false
	quest_menu_closed.emit()

func show_in_progress_quest(npc):
	quest_menu_opened.emit()
	$InProgressQuest/Name.text = npc.npc_name
	$InProgressQuest/Text.text = quest.progress_text
	$InProgressQuest.visible = true
	await get_tree().create_timer(3).timeout
	$InProgressQuest.visible = false
	quest_menu_closed.emit()

func show_finish_quest(npc):
	quest_menu_opened.emit()
	$FinishedQuest/Name.text = npc.npc_name
	$FinishedQuest.visible = true
	await get_tree().create_timer(3).timeout
	$FinishedQuest.visible = false
	quest_menu_closed.emit()

func _on_yes_button_1_pressed():
	$Quest.visible = false
	if quest:
		player.start_quest(quest)
		#quest.start()
	quest_menu_closed.emit()

func _on_no_button_1_pressed():
	$Quest.visible = false
	quest_menu_closed.emit()

