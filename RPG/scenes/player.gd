extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALKING
}

@export var inventory : Inventory
@onready var camera = $Camera2D

var speed : int = 100
var player_state : PlayerState = PlayerState.IDLE;
var bow_equipped = false
var bow_cooldown = true
var arrow_scene : PackedScene = preload("res://scenes/arrow.tscn")
var mouse_direction = null

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	player_state = (
		PlayerState.IDLE 
		if (direction.x == 0 and direction.y == 0)
		 else PlayerState.WALKING
		)

	mouse_direction = (get_global_mouse_position() - position).normalized()

	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("ui_fire") and bow_equipped and bow_cooldown:
		bow_cooldown = false
		shoot_arrow()

	if Input.is_action_just_pressed("ui_equip"):
		bow_equipped = not bow_equipped

	play_animation(mouse_direction if bow_equipped else direction)

func shoot_arrow():
	var mouse_position = get_global_mouse_position()
	$Marker2D.look_at(mouse_position)
	var arrow = arrow_scene.instantiate()
	arrow.rotation = $Marker2D.rotation
	arrow.global_position = $Marker2D.global_position
	add_child(arrow)
	$ShootTimer.start()
	
func play_animation(direction):
	if player_state == PlayerState.IDLE and not bow_equipped:
		$AnimatedSprite2D.play("idle")
	else:
		var animation = "attack" if bow_equipped else "walk"
		var animation_dir = "s"
		if direction.x > 0:
			if direction.y > 0.3:
				animation_dir = "se"
				#$AnimatedSprite2D.play("se-walk")
			elif direction.y < -0.3:
				animation_dir = "ne"
				#$AnimatedSprite2D.play("ne-walk")
			else:
				animation_dir = "e"
				#$AnimatedSprite2D.play("e-walk")
		elif direction.x < 0:
			if direction.y > 0.3:
				animation_dir = "sw"
				#$AnimatedSprite2D.play("sw-walk")
			elif direction.y < -0.3:
				animation_dir = "nw"
				#$AnimatedSprite2D.play("nw-walk")
			else:
				animation_dir = "w"
				#$AnimatedSprite2D.play("w-walk")
		elif direction.y > 0:
			animation_dir = "s"
			#$AnimatedSprite2D.play("s-walk")
		elif direction.y < 0:
			animation_dir = "n"
			#$AnimatedSprite2D.play("n-walk")

		$AnimatedSprite2D.play(animation_dir + "-" + animation)

func collect(object):
	inventory.insert(object.item)
	object.item.collect_item(object)

func _on_shoot_timer_timeout():
	bow_cooldown = true
