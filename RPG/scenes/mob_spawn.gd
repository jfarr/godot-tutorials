extends Node2D

@export var template : PackedScene
@export var wait_time = 30.0

var alive = true

func _ready():
	await get_tree().create_timer(0.01).timeout
	spawn()
	$Timer.wait_time = wait_time
	$Timer.start()

func spawn():
	var scene = template.instantiate()
	scene.global_position = global_position
	get_parent().add_child(scene)
	scene.mob.mob_killed.connect(on_mob_killed)

func on_mob_killed(_item):
	alive = false

func _on_timer_timeout():
	if !alive:
		spawn()
		alive = true
