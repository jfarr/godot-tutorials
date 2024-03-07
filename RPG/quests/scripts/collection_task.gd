extends Task

class_name CollectionTask

@export var quest_item : InventoryItem
@export var max_count = 0

func start():
	pass

func can_complete(player):
	return player.inventory.contains_items(quest_item, max_count)

func complete(player):
	player.inventory.remove_items(quest_item, max_count)

func get_display_text():
	return "Collect " + quest_item.name
