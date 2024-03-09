extends Node2D

@export var color = ""
@onready var sprite = get_node("Sprite2D")
@onready var arrow = get_node("Polygon2D")
var matched = false
var direction = null

func _ready():
	get_node("Polygon2D").visible = false

func move(target):
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'position', target, 0.2)

func dim():
	sprite.modulate = Color(1, 1, 1, 0.5)

func show_arrow():
	if direction != null:
		arrow.rotation = direction.angle_to(Vector2(1, 0))
		arrow.visible = true
