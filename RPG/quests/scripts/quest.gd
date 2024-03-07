extends Resource

class_name Quest

enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETE
}

#signal quest_started(quest : Quest)
#signal quest_completed(quest : Quest)

@export var id : String = ""
@export_multiline var text : String
@export_multiline var progress_text : String
@export var status : Status = Status.NOT_STARTED
@export var prereqs : Array[Quest]
@export var collection_tasks : Array[CollectionTask]
@export var kill_tasks : Array[KillTask]

#static func connect_quest_started(sink):
	#quest_started.connect(sink)

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
	#quest_started.emit(self)

func can_complete(player):
	for task in collection_tasks:
		if !task.can_complete(player):
			return false
	for task in kill_tasks:
		if !task.can_complete(player):
			return false
	return true

func complete(player):
	for task in collection_tasks:
		task.complete(player)
	for task in kill_tasks:
		task.complete(player)
	status = Status.COMPLETE
	#quest_completed.emit(self)

func get_tasks():
	return collection_tasks + kill_tasks
