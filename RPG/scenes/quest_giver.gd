extends Node2D

@export var quest_list : QuestList

var player_in_chat_area = false
var quest_dialog_active = false
var player = null

func process(_delta):
	if player_in_chat_area and Input.is_action_just_pressed("ui_use") and !quest_dialog_active:
		next_quest()           

func next_quest():
	for quest in quest_list.quests:
		if quest.status == Quest.Status.IN_PROGRESS and quest.can_complete(player):
			player.complete_quest(quest)
			#quest.turn_in(player)
			$NPCQuestDialog.show_finish_quest(get_parent())
			return
		if quest.status == Quest.Status.NOT_STARTED and quest.can_start():
			$NPCQuestDialog.show_quest(player, get_parent(), quest)
			return
	for quest in quest_list.quests:
		if quest.status == Quest.Status.IN_PROGRESS and not quest.can_complete(player):
			$NPCQuestDialog.show_in_progress_quest(get_parent())
	$NPCQuestDialog.show_no_quest(get_parent())

func _on_chat_area_body_entered(body):
	player_in_chat_area = true
	player = body

func _on_chat_area_body_exited(_body):
	player_in_chat_area = false

func _on_npc_quest_dialog_quest_menu_opened():
	quest_dialog_active = true

func _on_npc_quest_dialog_quest_menu_closed():
	quest_dialog_active = false
