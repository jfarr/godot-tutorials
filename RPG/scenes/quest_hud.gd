extends Node2D

func _ready():
	update(null, [])

func update(player, quests : Array[Quest]):
	var quest_panels = $Panel/GridContainer/Quests.get_children()
	for quest_panel in quest_panels:
		quest_panel.visible = false
	var active_quests = quests.filter(func(quest): return quest.status == quest.Status.IN_PROGRESS)
	var tasks = []
	for quest in active_quests:
		tasks.append_array(quest.get_tasks())
	for i in range(tasks.size()):
		var task = tasks[i]
		quest_panels[i].visible = true
		quest_panels[i].update(player, task)
