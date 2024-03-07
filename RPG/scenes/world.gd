extends Node2D

func _on_quests_updated(quests):
	$HUDLayer/QuestHUD.update($Player, quests)
