extends Node2D

#@export var item : InventoryItem

var stick_scene : PackedScene = preload("res://scenes/stick_collectible.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()

func spawn():
	var stick = stick_scene.instantiate()
	stick.item.item_collected.connect(on_item_collected)
	stick.global_position = global_position
	get_parent().add_child(stick)

func on_item_collected(_item):
	$Timer.wait_time = 6
	$Timer.start()

func _on_timer_timeout():
	print("spawning stick")
	spawn()
