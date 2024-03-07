extends StaticBody2D

@export var item : InventoryItem

func _on_interactable_area_body_entered(body):
	player_collect(body)

func player_collect(player):
	player.collect(self)
	self.queue_free()
