class_name Player
extends CharacterBody2D

const SPEED = 300.0

static var instance: Player

var last_direction: Vector2 = Vector2.RIGHT
var current_interactable: Interactable = null
var is_input_enabled: bool = true

@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_ray: RayCast2D = $InteractionRay
@onready var interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
	instance = self
	interaction_prompt.visible = false


func _physics_process(_delta: float) -> void:
	if not is_input_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
	if direction:
		velocity = direction * SPEED
		last_direction = direction
		# Update interaction ray direction
		interaction_ray.target_position = last_direction * 100.0
		interaction_ray.rotation = last_direction.angle()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

	# Check for potential interactables
	update_interaction()


func _input(event: InputEvent) -> void:
	if not is_input_enabled:
		return

	if event.is_action_pressed(&"interact") and current_interactable:
		current_interactable.interact()


func update_interaction() -> void:
	# Check if current interactable is still valid
	if current_interactable and (!is_instance_valid(current_interactable) or current_interactable.get_parent() == null):
		interaction_prompt.visible = false
		current_interactable = null

	var potential_interactable := get_nearest_interactable()

	if potential_interactable != current_interactable:
		if current_interactable:
			interaction_prompt.visible = false

		current_interactable = potential_interactable

		if current_interactable and current_interactable.is_active:
			interaction_prompt.text = current_interactable.interaction_prompt
			interaction_prompt.visible = true
	elif current_interactable:
		# Update visibility based on active status
		interaction_prompt.visible = current_interactable.is_active


func get_nearest_interactable() -> Interactable:
	# Check if ray is colliding with an interactable area
	if interaction_ray.is_colliding():
		var collider := interaction_ray.get_collider()

		# Check if the collider is the InteractionArea of an object
		if collider is Area2D and collider.get_parent() and collider.get_parent().has_node("Interactable"):
			return collider.get_parent().get_node("Interactable")
		# Check if collider has an Interactable directly
		elif collider and collider.has_node("Interactable"):
			return collider.get_node("Interactable")

	# Check for interactable areas nearby
	var interactables := []

	# Check overlapping areas first
	var areas := interaction_area.get_overlapping_areas()

	for area in areas:
		var parent := area.get_parent()
		if parent and parent.has_node("Interactable"):
			var interactable := parent.get_node("Interactable")

			# Check if in general direction where player is facing
			var dir_to_area: Vector2 = (parent.global_position - global_position).normalized()
			var dot_product := dir_to_area.dot(last_direction)

			if dot_product > 0.3: # At least somewhat facing it
				interactables.append({
					"interactable": interactable,
					"distance": global_position.distance_to(parent.global_position)
				})

	# Then check overlapping bodies
	var bodies := interaction_area.get_overlapping_bodies()

	for body in bodies:
		if body.has_node("Interactable"):
			var interactable := body.get_node("Interactable")

			# Check if in general direction where player is facing
			var dir_to_body := (body.global_position - global_position).normalized()
			var dot_product := dir_to_body.dot(last_direction)

			if dot_product > 0.3: # At least somewhat facing it
				interactables.append({
					"interactable": interactable,
					"distance": global_position.distance_to(body.global_position)
				})

	# Sort by distance and return closest
	if interactables.size() > 0:
		interactables.sort_custom(func(a, b): return a.distance < b.distance)
		return interactables[0].interactable

	return null


func _on_area_entered(_area: Area2D) -> void:
	update_interaction()


func _on_area_exited(_area: Area2D) -> void:
	update_interaction()


func set_input_enabled(enabled: bool) -> void:
	is_input_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
		interaction_prompt.visible = false
	else:
		update_interaction()
