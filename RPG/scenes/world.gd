extends Node2D

func _on_quests_updated(quests):
	print("updating quests")
	$HUDLayer/QuestHUD.update($Player, quests)
