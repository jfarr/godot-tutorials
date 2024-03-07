extends Panel

func update(player, task):
	$QuestLabel.text = task.get_display_text()
	$ProgressLabel.text = task.get_progress_text(player)
