extends Node2D

@export var quest_list : QuestList

func next_quest():
	for quest in quest_list.quests:
		if quest.status == Quest.Status.IN_PROGRESS and quest.is_completed():
			quest.turn_in()
			$NPCQuestDialog.play_finish_quest()
			return
		if quest.status == Quest.Status.NOT_STARTED:
			$NPCQuestDialog.show_quest(get_parent(), quest)
			return
	$NPCQuestDialog.show_no_quest()
