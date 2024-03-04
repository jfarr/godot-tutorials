extends Resource

class_name Quest

enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETE
}

@export var id : String = ""
@export_multiline var text : String
@export var status : Status = Status.NOT_STARTED
@export var prereqs : Array[Quest]
@export var collection_tasks : Array[CollectionTask]

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
	status = Status.IN_PROGRESS

func is_completed():
	for task in collection_tasks:
		if !task.is_completed():
			return false
	return true

func turn_in():
	status = Status.COMPLETE
