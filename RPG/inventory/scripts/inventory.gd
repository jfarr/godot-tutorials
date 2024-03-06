extends Resource

class_name Inventory

signal update

@export var slots : Array[InventorySlot]

func insert(item : InventoryItem):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		item_slots[-1].amount += 1
	else:
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
	update.emit()

func contains_items(item : InventoryItem, count : int = 1):
	var current_count = 0
	var item_slots = slots.filter(func(slot): return slot.item == item)
	for slot in item_slots:
		current_count += slot.amount
	return current_count >= count

func remove_items(item : InventoryItem, count : int = 1):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	for slot in item_slots:
		if slot.amount >= count:
			slot.amount -= count
			if slot.amount == 0:
				slot.item = null
		else:
			count -= slot.amount
			slot.item = null
			slot.amount = 0
			if count <= 0:
				break
	update.emit()

