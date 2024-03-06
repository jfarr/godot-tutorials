extends Node2D

@export var quest_list : QuestList

var player_in_chat_area = false

func process(_delta):
	if player_in_chat_area and Input.is_action_just_pressed("ui_use"):
		next_quest()

func next_quest():
	for quest in quest_list.quests:
		if quest.status == Quest.Status.IN_PROGRESS and quest.is_completed():
			quest.turn_in()
			$NPCQuestDialog.show_finish_quest(get_parent())
			return
		if quest.status == Quest.Status.NOT_STARTED:
			$NPCQuestDialog.show_quest(get_parent(), quest)
			return
	for quest in quest_list.quests:
		if quest.status == Quest.Status.IN_PROGRESS and not quest.is_completed():
			$NPCQuestDialog.show_in_progress_quest(get_parent())
	$NPCQuestDialog.show_no_quest(get_parent())

func _on_chat_area_body_entered(body):
	player_in_chat_area = true

func _on_chat_area_body_exited(body):
	player_in_chat_area = false
