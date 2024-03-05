extends Node2D

enum State {
	IDLE,
	NEW_DIR,
	MOVE
}

var speed = 30
var current_state = State.IDLE
var direction = Vector2.RIGHT
var is_roaming = true

func start(quest_dialog : NPCQuest):
	randomize()
	quest_dialog.quest_menu_opened.connect(_on_npc_quest_quest_menu_opened)
	quest_dialog.quest_menu_closed.connect(_on_npc_quest_quest_menu_closed)

func process(mob : CharacterBody2D, delta):
	animate(mob)
	if is_roaming:
		match current_state:
			State.NEW_DIR:
				direction = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			State.MOVE:
				move(mob, delta)

func animate(mob : CharacterBody2D):
	var sprite = mob.sprite
	if !is_roaming or current_state == State.IDLE or current_state == State.NEW_DIR:
		sprite.play("idle")
	elif current_state == State.MOVE:
		if direction.x == -1:
			sprite.play("w-walk")
		elif direction.x == -1:
			sprite.play("e-walk")
		elif direction.y == -1:
			sprite.play("n-walk")
		elif direction.y == 1:
			sprite.play("x-walk")

func choose(choices):
	choices.shuffle()
	return choices.front()

func move(mob, delta):
	mob.velocity = direction * speed
	mob.move_and_slide()

func _on_npc_quest_quest_menu_opened():
	is_roaming = false

func _on_npc_quest_quest_menu_closed():
	is_roaming = true

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0, 1.5])
	current_state = choose([State.IDLE, State.NEW_DIR, State.MOVE])
