extends Resource

class_name Quest

enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETE
}

signal quest_completed(quest : Quest)

@export var id : String = ""
@export_multiline var text : String
@export_multiline var progress_text : String
@export var status : Status = Status.NOT_STARTED
@export var prereqs : Array[Quest]
@export var collection_tasks : Array[CollectionTask]
@export var kill_tasks : Array[KillTask]

func can_start():
	if status != Status.NOT_STARTED:
		return false
	for prereq in prereqs:
		if !prereq.status == Status.COMPLETE:
			return false
	return true

func start():
	for task in collection_tasks:
		task.start()
	for task in kill_tasks:
		task.start()
	status = Status.IN_PROGRESS

func is_completed(player):
	for task in collection_tasks:
		if !task.is_completed(player):
			return false
	for task in kill_tasks:
		if !task.is_completed(player):
			return false
	return true

func turn_in(player):
	for task in collection_tasks:
		task.turn_in(player)
	for task in kill_tasks:
		task.turn_in(player)
	status = Status.COMPLETE
	quest_completed.emit(self)
