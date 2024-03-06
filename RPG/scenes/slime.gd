extends CharacterBody2D

var mob_name = "slime"
#var speed = 50
var health = 100
#var damage
#var dead = false
#var player_in_area = false
#var player = null

@onready var sprite = $AnimatedSprite2D
@onready var slime_scene = $SlimeCollectible

@export var slime_item : InventoryItem

func _ready():
	$MOB.start(self)

func _physics_process(delta):
	$MOB.process(delta)
#
#func _on_detection_area_body_entered(body):
	#player_in_area = true
	#player = body
#
#func _on_detection_area_body_exited(body):
	#player_in_area = false

func _on_hitbox_area_entered(area):
	var damage = 50
	take_damage(damage)

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	$MOB.die()
	#$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1).timeout
	
	drop_slime()
	
	$AnimatedSprite2D.visible = false
	$Hitbox/CollisionShape2D.disabled = true
	#$DetectionArea/CollisionShape2D.disabled = true

func drop_slime():
	slime_scene.visible = true
	$CollectionArea/CollisionShape2D.disabled = false
	await get_tree().create_timer(1).timeout
	slime_collect()

func slime_collect():
	slime_scene.visible = false
	#player.collect(slime_item)
	queue_free()

func _on_collection_area_body_entered(body):
	#player = body
	pass

