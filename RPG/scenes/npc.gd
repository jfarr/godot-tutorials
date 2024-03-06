extends CharacterBody2D

const npc_name = "Worker Bob"

@onready var sprite = $AnimatedSprite2D

func _ready():
	$MOB.start(self)

func _process(delta):
	$NPCChat.process(delta)

func _physics_process(delta):
	$MOB.process(delta)
