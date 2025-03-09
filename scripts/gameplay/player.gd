extends CharacterBody2D


const SPEED = 300.0


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
