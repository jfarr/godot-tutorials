extends CharacterBody2D

var mob_name = "slime"

@onready var sprite = $AnimatedSprite2D

@export var collectible : PackedScene

func _ready():
	$MOB.start(self)

func _physics_process(delta):
	$MOB.process(delta)
