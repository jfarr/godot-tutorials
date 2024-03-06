extends CharacterBody2D

const npc_name = "Worker Dave"

@onready var sprite = $AnimatedSprite2D

func _ready():
	$MOB.start(self)

func _process(delta):
	$QuestGiver.process(delta)

func _physics_process(delta):
	$MOB.process(delta)
