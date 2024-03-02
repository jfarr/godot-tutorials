extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALKING
}

@export var inventory : Inventory

var speed : int = 100
var player_state : PlayerState = PlayerState.IDLE;

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	player_state = (
		PlayerState.IDLE 
		if (direction.x == 0 and direction.y == 0)
		 else PlayerState.WALKING
		)

	velocity = direction * speed
	move_and_slide()
	
	play_animation(direction)
	
func play_animation(direction):
	if player_state == PlayerState.IDLE:
		$AnimatedSprite2D.play("idle")
	elif player_state == PlayerState.WALKING:
		if direction.x > 0:
			if direction.y > 0:
				$AnimatedSprite2D.play("se-walk")
			elif direction.y < 0:
				$AnimatedSprite2D.play("ne-walk")
			else:
				$AnimatedSprite2D.play("e-walk")
		elif direction.x < 0:
			if direction.y > 0:
				$AnimatedSprite2D.play("sw-walk")
			elif direction.y < 0:
				$AnimatedSprite2D.play("nw-walk")
			else:
				$AnimatedSprite2D.play("w-walk")
		elif direction.y > 0:
			$AnimatedSprite2D.play("s-walk")
		elif direction.y < 0:
			$AnimatedSprite2D.play("n-walk")

func collect(item : InventoryItem):
	inventory.insert(item)
