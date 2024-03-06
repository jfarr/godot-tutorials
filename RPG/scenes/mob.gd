extends Node2D

var speed = 50
var dead = false
var health = 100
var player_in_area = false
var mob = null
var player = null

func start(mob : CharacterBody2D):
	self.mob = mob
	$RandomPath.start(mob)

func process(delta):
	if !dead:
		if player_in_area:
			move()
		else:
			$RandomPath.process(delta)
	animate()

func move():
	var direction : Vector2 = (player.get_global_position() - get_global_position()).normalized()
	mob.velocity = direction * speed
	mob.move_and_slide()

func animate():
	if dead:
		mob.sprite.play("death")
	elif player_in_area:
		mob.sprite.play("move")

func die():
	dead = true
	$DetectionArea/CollisionShape2D.disabled = true

func _on_detection_area_body_entered(body):
	player_in_area = true
	player = body

func _on_detection_area_body_exited(body):
	player_in_area = false
