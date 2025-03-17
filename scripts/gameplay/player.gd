class_name Player
extends CharacterBody2D

const SPEED = 350.0
const CREAK_CHANCE: float = 0.01

static var instance: Player

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_input_enabled: bool = true
var current_interactable: Interactable = null
var footstep_time: float = 0.0
var footstep_interval: float = 0.5

@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_prompt: Label = $InteractionPrompt

@export var location_footsteps: Dictionary[LocationService.Location, AudioStream]
@export var wood_creak: AudioStream


func _ready() -> void:
	instance = self # Set the singleton.
	interaction_prompt.visible = false


## Handles player movement.
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
	if direction and is_input_enabled:
		velocity = direction * SPEED
		sprite.play(&"walk")

		# Play footstep sounds when walking
		footstep_time += delta
		if footstep_time >= footstep_interval:
			var location = LocationService.get_location()
			var footstep_sound = location_footsteps.get(location)

			if footstep_sound:
				AudioService.play_sfx(footstep_sound, global_position)

			# Random chance to play wood creak sound only when in Cabin
			if location == LocationService.Location.CABIN and randf() < CREAK_CHANCE:
				AudioService.play_sfx(wood_creak, global_position)

			footstep_time = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		sprite.play(&"idle")
		# Reset footstep timer when not moving
		footstep_time = 0.0

	if not is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x < 0

	move_and_slide()


## Handles player interaction.
func _input(event: InputEvent) -> void:
	if not is_input_enabled:
		return

	if event.is_action_pressed(&"interact") and current_interactable:
		current_interactable.interact()


## Updates the interaction prompt.
func update_interaction() -> void:
	current_interactable = get_nearest_interactable()
	if current_interactable:
		interaction_prompt.text = current_interactable.interaction_prompt
		interaction_prompt.visible = current_interactable.is_active
	else:
		interaction_prompt.hide()


## Returns the nearest `Interactable` in the interaction area.
func get_nearest_interactable() -> Interactable:
	var interactables: Dictionary[Interactable, float] = {}

	# Check all bodies in the interaction area.
	var bodies := interaction_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_node("Interactable"):
			var interactable := body.get_node("Interactable") as Interactable
			interactables[interactable] = global_position.distance_to(body.global_position)

	# Find the nearest interactable (if any).
	var closest_interactable: Interactable = null
	var closest_distance := INF
	for interactable in interactables:
		var distance := interactables[interactable]
		if distance < closest_distance:
			closest_distance = distance
			closest_interactable = interactable

	return closest_interactable


## Handles player state when enabling/disabling input.
func set_input_enabled(enabled: bool) -> void:
	is_input_enabled = enabled
	if not enabled:
		interaction_prompt.hide()
	else:
		update_interaction()


func _on_body_entered(_body: Node2D) -> void:
	update_interaction()


func _on_body_exited(_body: Node2D) -> void:
	update_interaction()
