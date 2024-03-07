extends StaticBody2D

@export var item : InventoryItem

var player = null

func _on_interactable_area_body_entered(body):
	player = body
	player_collect()

func player_collect():
	player.collect(self)
	self.queue_free()
