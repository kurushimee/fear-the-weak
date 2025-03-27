class_name Locator
extends Node2D

@export var destinations: Array[Node2D] = []

@export var min_beep_delay: float = 0.2
@export var max_beep_delay: float = 2.0

@export var destination_reached_distance: float = 100.0
@export var max_distance: float = 1000.0

@export var beep_stream: AudioStream
@export var destination_reached_stream: AudioStream
@export var next_destination_stream: AudioStream

var current_destination_index: int = -1
var is_active: bool = false
var beep_timer: float = 0.0
var current_beep_delay: float = max_beep_delay


func _process(delta: float) -> void:
	# Only process when in the Forest location
	if not is_active or current_destination_index == -1:
		return

	# Skip processing if not in forest
	if LocationService.get_location() != LocationService.Location.FOREST:
		return

	var current_destination := get_current_destination()
	if not current_destination:
		return

	# Calculate distance to destination
	var distance := Player.instance.global_position.distance_to(current_destination.global_position)

	# Check if destination reached
	if distance <= destination_reached_distance:
		AudioService.play_sfx(destination_reached_stream)
		is_active = false
		return

	# Calculate beep delay based on distance
	var distance_ratio := clampf((distance - destination_reached_distance) /
					(max_distance - destination_reached_distance), 0.0, 1.0)
	current_beep_delay = lerpf(min_beep_delay, max_beep_delay, distance_ratio)

	# Update beep timer
	beep_timer += delta
	if beep_timer >= current_beep_delay:
		AudioService.play_sfx(beep_stream)
		beep_timer = 0.0


## Activates the locator with the first destination
func activate() -> void:
	if destinations.is_empty():
		push_warning("Locator: No destinations set")
		return

	current_destination_index += 1
	AudioService.play_sfx(next_destination_stream)
	is_active = true
	beep_timer = 0.0


## Returns the current destination Node2D if any, otherwise `null`
func get_current_destination() -> Node2D:
	if current_destination_index >= 0 and current_destination_index < destinations.size():
		return destinations[current_destination_index]
	return null
