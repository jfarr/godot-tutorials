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
var mob = null

func start(mob : CharacterBody2D):
	self.mob = mob
	randomize()
	if "quest_dialog" in mob.get_property_list() and mob.quest_dialog:
		mob.quest_dialog.quest_menu_opened.connect(_on_npc_quest_quest_menu_opened)
		mob.quest_dialog.quest_menu_closed.connect(_on_npc_quest_quest_menu_closed)

func process(delta):
	animate()
	if is_roaming:
		match current_state:
			State.NEW_DIR:
				direction = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			State.MOVE:
				move(delta)

func animate():
	var sprite = mob.sprite
	if !is_roaming or current_state == State.IDLE or current_state == State.NEW_DIR:
		sprite.play("idle")
	elif current_state == State.MOVE:
		if direction.x == -1:
			sprite.play("w-walk")
		elif direction.x == 1:
			sprite.play("e-walk")
		elif direction.y == -1:
			sprite.play("n-walk")
		elif direction.y == 1:
			sprite.play("s-walk")

func choose(choices):
	choices.shuffle()
	return choices.front()

func move(delta):
	mob.velocity = direction * speed
	mob.move_and_slide()

func _on_npc_quest_quest_menu_opened():
	is_roaming = false

func _on_npc_quest_quest_menu_closed():
	is_roaming = true

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0, 1.5])
	current_state = choose([State.IDLE, State.NEW_DIR, State.MOVE])
