extends Panel

func update(task):
	$QuestLabel.text = task.get_display_text()
	#$ProgressLabel.text = ""
