extends CharacterBody2D

var mob_name = "slime"

@onready var sprite = $AnimatedSprite2D
@onready var mob = $MOB.resource

@export var collectible : PackedScene

func _ready():
	$MOB.start(self)

func _physics_process(delta):
	$MOB.process(delta)
