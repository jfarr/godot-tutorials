extends StaticBody2D

@export var item : InventoryItem

func _ready():
	$AnimationPlayer.play("falling")

func _on_interactable_area_body_entered(body):
	player_collect(body)

func player_collect(player):
	player.collect(item)
	self.queue_free()
