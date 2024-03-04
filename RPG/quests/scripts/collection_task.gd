extends Resource

class_name CollectionTask

@export var quest_item : InventoryItem
@export var max_count = 0
var count = 0

func start():
	quest_item.item_collected.connect(collect_item)

func collect_item(item : InventoryItem):
	if item.name == quest_item.name:
		if !max_count or count < max_count:
			count += 1

func is_completed():
	return count == max_count
