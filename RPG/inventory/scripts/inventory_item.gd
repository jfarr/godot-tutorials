extends Resource

class_name InventoryItem

signal item_collected(object)

@export var name : String = ""
@export var texture : Texture2D

func collect_item(object):
	item_collected.emit(object)
