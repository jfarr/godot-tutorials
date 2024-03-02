extends Panel

@onready var item_visual : Sprite2D = $CenterContainer/Panel/ItemSprite
@onready var amount_text : Label = $CenterContainer/Panel/Label

func update(slot: InventorySlot):
	if not slot.item:
		item_visual.visible = false
		amount_text.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		amount_text.visible = slot.amount > 1
		amount_text.text = str(slot.amount)
