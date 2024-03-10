extends Node2D

@export var color = ""
@onready var sprite = get_node("Sprite2D")
@onready var marker = get_node("Polygon2D")
var anchor = false
var matched = false
var scene : PackedScene

func _ready():
	get_node("Polygon2D").visible = anchor

func move(target):
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'position', target, 0.2)

func dim():
	sprite.modulate = Color(1, 1, 1, 0.5)

func show_marker():
	#marker.visible = true
	pass

