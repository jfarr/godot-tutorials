extends Task

class_name KillTask

@export var quest_mob : MOBResource
@export var max_count = 0
var count = 0

func start():
	quest_mob.mob_killed.connect(collect_kill)

func collect_kill(mob):
	if mob.resource.name == quest_mob.name and count < max_count:
		count += 1

func can_complete(_player):
	return count == max_count

func complete(_player):
	pass

func get_display_text():
	return "Kill " + quest_mob.name
