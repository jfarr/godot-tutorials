extends Node2D

@export var template : PackedScene
@export var wait_time = 6.0

func _ready():
	$Timer.wait_time = wait_time
	await get_tree().create_timer(0.01).timeout
	spawn()

func spawn():
	var scene = template.instantiate()
	scene.item.item_collected.connect(on_item_collected)
	scene.global_position = global_position
	get_parent().add_child(scene)

func on_item_collected(_item):
	$Timer.start()

func _on_timer_timeout():
	spawn()
