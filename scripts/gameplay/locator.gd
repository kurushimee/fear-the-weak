class_name Locator
extends Node2D

signal destination_reached

@export var destinations: Array[Node2D] = []

@export var min_beep_delay: float = 0.2
@export var max_beep_delay: float = 2.0

@export var destination_reached_distance: float = 100.0
@export var max_distance: float = 1000.0

@onready var beep_player: AudioStreamPlayer = $BeepPlayer
@onready var destination_reached_player: AudioStreamPlayer = $DestinationReachedPlayer
@onready var next_destination_player: AudioStreamPlayer = $NextDestinationPlayer

var current_destination_index: int = -1
var is_active: bool = false
var beep_timer: float = 0.0
var current_beep_delay: float = max_beep_delay


## Activates the locator with the first destination
func activate() -> void:
	if destinations.is_empty():
		push_warning("Locator: No destinations set")
		return

	if current_destination_index == -1:
		# First activation
		current_destination_index = 0
	else:
		# Move to next destination
		current_destination_index = (current_destination_index + 1) % destinations.size()

	# Play activation sound
	next_destination_player.play()

	is_active = true
	beep_timer = 0.0


## Deactivates the locator
func deactivate() -> void:
	is_active = false


## Returns the current destination Node2D
func get_current_destination() -> Node2D:
	if current_destination_index >= 0 and current_destination_index < destinations.size():
		return destinations[current_destination_index]
	return null


func _process(delta: float) -> void:
	if not is_active or current_destination_index == -1:
		return

	var current_destination := get_current_destination()
	if not current_destination:
		return

	# Calculate distance to destination
	var distance := Player.instance.global_position.distance_to(current_destination.global_position)

	# Check if destination reached
	if distance <= destination_reached_distance:
		# Play destination reached sound
		destination_reached_player.play()

		# Emit signal
		destination_reached.emit()

		# Deactivate locator
		deactivate()
		return

	# Calculate beep delay based on distance
	var distance_ratio := clampf((distance - destination_reached_distance) /
							(max_distance - destination_reached_distance), 0.0, 1.0)
	current_beep_delay = lerpf(min_beep_delay, max_beep_delay, distance_ratio)

	# Update beep timer
	beep_timer += delta
	if beep_timer >= current_beep_delay:
		# Play beep sound
		beep_player.play()

		# Reset timer
		beep_timer = 0.0
