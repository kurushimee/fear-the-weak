class_name RadioMinigameUI
extends Control

signal minigame_completed

const FREQUENCY_MIN: float = 87.5
const FREQUENCY_MAX: float = 108.0
const REQUIRED_TIME_ON_FREQUENCY: float = 1.0
const CURSOR_SPEED: float = 10.0
const CURSOR_ACCELERATION: float = 50.0
const LINE_WIDTH: float = 400.0
const TARGET_PROXIMITY_THRESHOLD: float = 0.1 # How long the cursor has to stay on target
const MAX_DISTANCE: float = 2.0 # Maximum distance to show any proximity effect

var target_frequency: float
var current_frequency: float
var time_on_frequency: float
var is_active: bool = false
var current_cursor_velocity: float = 0.0 # Current velocity of the cursor
var current_audio_state: AudioState = AudioState.NONE

@onready var frequency_label: Label = $FrequencyLabel
@onready var static_sfx: AudioStreamPlayer = $StaticSFX
@onready var near_freq_sfx: AudioStreamPlayer = $NearFreqSFX
@onready var on_freq_sfx: AudioStreamPlayer = $OnFreqSFX

enum AudioState {
	NONE,
	STATIC,
	NEAR_FREQ,
	ON_FREQ
}

func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if not is_active:
		return

	# Handle cursor acceleration
	if Input.is_action_pressed(&"move_left"):
		# Accelerate left (negative direction)
		if current_cursor_velocity >= 0.0:
			current_cursor_velocity = 0.0
		current_cursor_velocity = maxf(current_cursor_velocity - CURSOR_ACCELERATION * delta, -CURSOR_SPEED)
	elif Input.is_action_pressed(&"move_right"):
		# Accelerate right (positive direction)
		if current_cursor_velocity <= 0.0:
			current_cursor_velocity = 0.0
		current_cursor_velocity = minf(current_cursor_velocity + CURSOR_ACCELERATION * delta, CURSOR_SPEED)
	else:
		# Reset to zero when no input
		current_cursor_velocity = 0.0

	# Apply velocity to frequency
	current_frequency = clampf(current_frequency + current_cursor_velocity * delta, FREQUENCY_MIN, FREQUENCY_MAX)
	queue_redraw()

	if abs(current_frequency - target_frequency) < TARGET_PROXIMITY_THRESHOLD:
		time_on_frequency += delta
		if time_on_frequency >= REQUIRED_TIME_ON_FREQUENCY:
			# Stop audio before completing minigame to prevent audio from playing after completion
			stop_all_audio()
			complete_minigame()
			return
	else:
		time_on_frequency = 0.0

	frequency_label.text = "%.1f MHz" % current_frequency
	update_audio_feedback()


func _draw() -> void:
	if not is_active:
		return

	var line_start := Vector2(size.x / 2 - LINE_WIDTH / 2, size.y / 2)
	var line_end := Vector2(size.x / 2 + LINE_WIDTH / 2, size.y / 2)

	# Draw the frequency line
	draw_line(line_start, line_end, Color.WHITE, 2.0)

	# Draw the target frequency indicator
	var target_x := line_start.x + (target_frequency - FREQUENCY_MIN) / (FREQUENCY_MAX - FREQUENCY_MIN) * LINE_WIDTH
	var target_pos := Vector2(target_x, size.y / 2)

	# Draw proximity guide
	var proximity := calculate_proximity()

	# Draw proximity circle that grows as player gets closer to target
	if proximity > 0.0:
		var proximity_radius := 10.0 + proximity * 15.0
		var proximity_color := Color(1.0, 0.3, 0.3, proximity)
		draw_circle(target_pos, proximity_radius, proximity_color)

	# Draw target indicator when very close
	if proximity >= 0.8:
		var pulse_intensity := (1.0 + sin(Time.get_ticks_msec() / 150.0)) / 2.0
		var target_color := Color(0.0, 1.0, 0.0, 0.5 + pulse_intensity * 0.5)
		draw_circle(target_pos, 5.0, target_color)

	# Draw the cursor
	var cursor_x := line_start.x + (current_frequency - FREQUENCY_MIN) / (FREQUENCY_MAX - FREQUENCY_MIN) * LINE_WIDTH
	var cursor_pos := Vector2(cursor_x, size.y / 2)

	# Change cursor color based on proximity
	var cursor_color: Color = Color.WHITE
	if proximity >= 0.8:
		cursor_color = Color.GREEN
	elif proximity > 0.0:
		# Properly interpolate between white and green based on proximity
		cursor_color = Color.WHITE.lerp(Color.GREEN, proximity)

	draw_line(cursor_pos - Vector2(0, 15), cursor_pos + Vector2(0, 15), cursor_color, 2.0)

	# Draw progress indicator when on target
	if proximity >= 0.8:
		var progress_ratio := time_on_frequency / REQUIRED_TIME_ON_FREQUENCY
		if progress_ratio > 0.0:
			var progress_height := 30.0
			var progress_width := 4.0
			var progress_pos := cursor_pos + Vector2(0, 20)
			var progress_rect := Rect2(
				progress_pos.x - progress_width / 2,
				progress_pos.y,
				progress_width,
				progress_height * progress_ratio
			)
			draw_rect(progress_rect, Color.GREEN, true)


func calculate_proximity() -> float:
	var _distance: float = abs(current_frequency - target_frequency)
	var max_distance: float = MAX_DISTANCE # Maximum distance to show any proximity effect

	if _distance > max_distance:
		return 0.0
	elif _distance < TARGET_PROXIMITY_THRESHOLD:
		return 1.0
	else:
		# Linear interpolation between 0 and 1 based on distance
		return 1.0 - (_distance - TARGET_PROXIMITY_THRESHOLD) / (max_distance - TARGET_PROXIMITY_THRESHOLD)


func start_minigame() -> void:
	target_frequency = randf_range(FREQUENCY_MIN, FREQUENCY_MAX)
	current_frequency = (FREQUENCY_MIN + FREQUENCY_MAX) / 2
	time_on_frequency = 0.0
	current_cursor_velocity = 0.0 # Reset cursor velocity
	is_active = true
	show()
	queue_redraw()

	# Start static sound when entering minigame
	static_sfx.play()
	current_audio_state = AudioState.STATIC


func complete_minigame() -> void:
	is_active = false
	hide()
	minigame_completed.emit()


func update_audio_feedback() -> void:
	var proximity := calculate_proximity()
	var new_state: AudioState

	if proximity >= 0.8: # Matches the green circle threshold in _draw
		new_state = AudioState.ON_FREQ
	elif proximity > 0.0: # Any proximity effect shows the red circle
		new_state = AudioState.NEAR_FREQ
	else:
		new_state = AudioState.STATIC

	if new_state != current_audio_state:
		match new_state:
			AudioState.ON_FREQ:
				static_sfx.stop()
				near_freq_sfx.stop()
				on_freq_sfx.play()
			AudioState.NEAR_FREQ:
				static_sfx.stop()
				near_freq_sfx.play()
				on_freq_sfx.stop()
			AudioState.STATIC:
				static_sfx.play()
				near_freq_sfx.stop()
				on_freq_sfx.stop()

		current_audio_state = new_state


func stop_all_audio() -> void:
	static_sfx.stop()
	near_freq_sfx.stop()
	on_freq_sfx.stop()
	current_audio_state = AudioState.NONE
