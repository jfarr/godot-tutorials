extends Node2D

@export var template : PackedScene
@export var wait_time = 6.0

var spawned_object = null

func _ready():
	$Timer.wait_time = wait_time
	await get_tree().create_timer(0.01).timeout
	spawn()

func spawn():
	spawned_object = template.instantiate()
	spawned_object.item.item_collected.connect(on_item_collected)
	spawned_object.global_position = global_position
	get_parent().add_child(spawned_object)

func on_item_collected(object):
	if object == spawned_object:
		$Timer.start()

func _on_timer_timeout():
	spawn()
