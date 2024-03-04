extends Resource

class_name InventoryItem

signal item_collected(item: InventoryItem)

@export var name : String = ""
@export var texture : Texture2D

func collect_item():
	item_collected.emit(self)
