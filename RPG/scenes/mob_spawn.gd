extends Node2D

@export var template : PackedScene
@export var wait_time = 30.0

var spawned_mob = null
var alive = true

func _ready():
	await get_tree().create_timer(0.01).timeout
	spawn()
	$Timer.wait_time = wait_time
	$Timer.start()

func spawn():
	spawned_mob = template.instantiate()
	spawned_mob.global_position = global_position
	get_parent().add_child(spawned_mob)
	spawned_mob.mob.mob_killed.connect(on_mob_killed)
 
func on_mob_killed(mob):
	if mob == spawned_mob:
		alive = false
		spawned_mob.queue_free()

func _on_timer_timeout():
	if !alive:
		spawn()
		alive = true
