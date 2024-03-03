extends StaticBody2D

@export var item : InventoryItem
var player = null

func _on_interactable_area_body_entered(body):
	player = body
	player_collect()
	
func player_collect():
	player.collect(item)
	print("stick collected")
	player.stick_collected.emit()
	await get_tree().create_timer(0.1).timeout
	self.queue_free()
