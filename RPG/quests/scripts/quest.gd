extends Resource

class_name Quest

enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETE
}

@export var id : String = ""
@export var text : String
@export var status : Status = Status.NOT_STARTED
@export var prereqs : Array[Quest]

func can_start():
	if status != Status.NOT_STARTED:
		return false
	for prereq in prereqs:
		if !prereq.status == Status.COMPLETE:
			return false
	return true
