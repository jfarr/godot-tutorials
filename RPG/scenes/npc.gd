extends CharacterBody2D

enum State {
	IDLE,
	NEW_DIR,
	MOVE
}

const npc_name = "Worker"
const speed = 30
var current_state = State.IDLE
var direction = Vector2.RIGHT

var is_roaming = true
var is_chatting = false
var player = null
var player_in_chat_area = false

func _ready():
	randomize()

func _process(delta):
	if current_state == State.IDLE or current_state == State.NEW_DIR:
		$AnimatedSprite2D.play("idle")
	elif current_state == State.MOVE and !is_chatting:
		if direction.x == -1:
			$AnimatedSprite2D.play("w-walk")
		elif direction.x == -1:
			$AnimatedSprite2D.play("e-walk")
		elif direction.y == -1:
			$AnimatedSprite2D.play("n-walk")
		elif direction.y == 1:
			$AnimatedSprite2D.play("x-walk")

	if is_roaming:
		match current_state:
			State.NEW_DIR:
				direction = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			State.MOVE:
				move(delta)
	
	if player_in_chat_area and Input.is_action_just_pressed("ui_use"):
		$Dialog.start()
		is_roaming = false
		is_chatting = true
		$AnimatedSprite2D.play("idle")
	elif player_in_chat_area and Input.is_action_just_pressed("ui_quest"):
		#$NPCQuest.next_quest()
		$QuestGiver.next_quest()
		is_roaming = false
		is_chatting = true
		$AnimatedSprite2D.play("idle")

func choose(choices):
	choices.shuffle()
	return choices.front()

func move(delta):
	if !is_chatting:
		velocity = direction * speed
		move_and_slide()

func _on_chat_area_body_entered(body):
	player = body
	player_in_chat_area = true

func _on_chat_area_body_exited(body):
	player_in_chat_area = false

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0, 1.5])
	current_state = choose([State.IDLE, State.NEW_DIR, State.MOVE])

func _on_dialog_dialog_finished():
	is_chatting = false
	is_roaming = true

func _on_npc_quest_quest_menu_closed():
	is_chatting = false
	is_roaming = true
