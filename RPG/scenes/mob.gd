extends Node2D

enum State {
	IDLE,
	NEW_DIR,
	MOVE
}

@export var resource : MOBResource
@export var walk_speed = 30
@export var run_speed = 50
@export var max_distance = 150
@export var hostile = false
@export var health = 100
@export var has_4way_sprite = true

var starting_pos : Vector2
var roaming = true
var current_state = State.IDLE
var direction = Vector2.RIGHT
var dead = false
var player_in_area = false
var mob = null
var player = null

func start(mob : CharacterBody2D):
	self.mob = mob
	starting_pos = mob.position
	randomize()
	var quest_dialog = mob.get_node_or_null("QuestGiver/NPCQuestDialog")
	if quest_dialog:
		quest_dialog.quest_menu_opened.connect(_on_npc_quest_quest_menu_opened)
		quest_dialog.quest_menu_closed.connect(_on_npc_quest_quest_menu_closed)
	var chat_dialog = mob.get_node_or_null("NPCChat/Dialog")
	if chat_dialog:
		chat_dialog.dialog_started.connect(_on_chat_dialog_dialog_started)
		chat_dialog.dialog_finished.connect(_on_chat_dialog_dialog_finished)

func process(_delta):
	if !dead:
		if hostile and player_in_area:
			chase()
		else:
			wander()
		animate()

func chase():
	direction = (player.get_global_position() - get_global_position()).normalized()
	move(run_speed)
	starting_pos = position

func wander():
	if roaming:
		match current_state:
			State.NEW_DIR:
				direction = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			State.MOVE:
				var distance = ((mob.position + direction * walk_speed) - starting_pos).length()
				if distance < max_distance:
					move(walk_speed)
				else:
					current_state = State.NEW_DIR

func move(speed):
	mob.velocity = direction * speed
	mob.move_and_slide()
	
func choose(choices):
	choices.shuffle()
	return choices.front()

func animate():
	var sprite = mob.sprite
	if !dead:
		if is_moving():
			if has_4way_sprite:
				if direction.x == -1:
					sprite.play("move-w")
				elif direction.x == 1:
					sprite.play("move-e")
				elif direction.y == -1:
					sprite.play("move-n")
				elif direction.y == 1:
					sprite.play("move-s")
			else:
				sprite.play("move")
		else:
			sprite.play("idle")

func is_moving():
	return (roaming and current_state == State.MOVE) or (hostile and player_in_area)

func _on_detection_area_body_entered(body):
	player_in_area = true
	player = body

func _on_detection_area_body_exited(_body):
	player_in_area = false

func _on_npc_quest_quest_menu_opened():
	roaming = false

func _on_npc_quest_quest_menu_closed():
	roaming = true

func _on_chat_dialog_dialog_started():
	roaming = false

func _on_chat_dialog_dialog_finished():
	roaming = true

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0, 1.5])
	current_state = choose([State.IDLE, State.NEW_DIR, State.MOVE])

func _on_hitbox_area_entered(_area):
	if hostile:
		var damage = 50
		take_damage(damage)

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	dead = true
	$Hitbox/CollisionShape2D.disabled = true
	$DetectionArea/CollisionShape2D.disabled = true
	mob.sprite.animation_finished.connect(on_death_animation_finished)
	mob.sprite.play("death")
	resource.mob_killed.emit(mob)
	drop_item()
	mob.queue_free()

func on_death_animation_finished():
	mob.sprite.visible = false
	mob.sprite.animation_finished.disconnect(on_death_animation_finished)

func drop_item():
	if mob.collectible:
		var drop = mob.collectible.instantiate()
		drop.global_position = global_position
		mob.get_parent().add_child(drop)
