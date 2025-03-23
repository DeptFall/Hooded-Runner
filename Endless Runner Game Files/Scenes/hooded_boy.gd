extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("Idle")
		else:
			$RunCol.disabled = false
		
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
				$RunCol.disabled = false
			elif Input.is_action_pressed("ui_up"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
				$RunCol.disabled = false
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("Duck")
				const GRAVITY: int = 9000
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Jump")
		
	move_and_slide()
