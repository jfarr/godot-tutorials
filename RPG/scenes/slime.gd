extends CharacterBody2D

var speed = 50
var health = 100
var damage
var dead = false
var player_in_area = false
var player = null

@onready var slime_scene = $SlimeCollectible
@export var slime_item : InventoryItem

func _ready():
	pass
	
func _physics_process(delta):
	if not dead:
		$DetectionArea/CollisionShape2D.disabled = false
		if player_in_area:
			var direction : Vector2 = (player.position - position).normalized()
			position += direction * speed * delta
			$AnimatedSprite2D.play("moving")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$DetectionArea/CollisionShape2D.disabled = true

func _on_detection_area_body_entered(body):
	player_in_area = true
	player = body

func _on_detection_area_body_exited(body):
	player_in_area = false

func _on_hitbox_area_entered(area):
	#var damage = 50
	take_damage(area.damage)

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	dead = true
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1).timeout
	
	drop_slime()
	
	$AnimatedSprite2D.visible = false
	$Hitbox/CollisionShape2D.disabled = true
	$DetectionArea/CollisionShape2D.disabled = true

func drop_slime():
	slime_scene.visible = true
	$CollectionArea/CollisionShape2D.disabled = false
	await get_tree().create_timer(1).timeout
	slime_collect()

func slime_collect():
	slime_scene.visible = false
	player.collect(slime_item)
	queue_free()

func _on_collection_area_body_entered(body):
	player = body
