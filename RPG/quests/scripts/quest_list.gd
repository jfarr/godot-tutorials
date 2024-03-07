extends Resource

class_name QuestList

signal quest_started(quest : Quest)
signal quest_completed(quest : Quest)

@export var quests : Array[Quest]

func start_quest(quest : Quest):
	quests.append(quest)
	quest.start()
	quest_started.emit(quest)

func complete_quest(player, quest : Quest):
	quest.complete(player)
	quest_completed.emit(quest)
