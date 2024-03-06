extends Resource

class_name CollectionTask

@export var quest_item : InventoryItem
@export var max_count = 0

func start():
	pass

func is_completed(player):
	return player.inventory.contains_items(quest_item, max_count)

func turn_in(player):
	player.inventory.remove_items(quest_item, max_count)
