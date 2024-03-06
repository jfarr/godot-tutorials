extends Resource

class_name MOBResource

signal mob_killed(mob: MOBResource)

@export var name : String

func kill():
	mob_killed.emit(self)
