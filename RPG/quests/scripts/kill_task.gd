extends Resource

class_name KillTask

@export var quest_mob : MOBResource
@export var max_count = 0
var count = 0

func start():
	quest_mob.mob_killed.connect(collect_kill)

func collect_kill(mob : MOBResource):
	if mob.name == quest_mob.name and count < max_count:
		count += 1

func is_completed(_player):
	return count == max_count

func turn_in(_player):
	pass
