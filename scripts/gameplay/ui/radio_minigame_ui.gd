class_name RadioMinigameUI
extends Control

signal minigame_completed

const FREQUENCY_MIN: float = 87.5
const FREQUENCY_MAX: float = 108.0
const REQUIRED_TIME_ON_FREQUENCY: float = 1.0
const CURSOR_SPEED: float = 15.0
const LINE_WIDTH: float = 400.0

var target_frequency: float
var current_frequency: float
var time_on_frequency: float
var is_active: bool = false

@onready var frequency_label: Label = $FrequencyLabel
@onready var feedback_player: AudioStreamPlayer = $FeedbackPlayer

func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if not is_active:
		return

	if Input.is_action_pressed("move_left"):
		current_frequency = maxf(FREQUENCY_MIN, current_frequency - delta * CURSOR_SPEED)
	elif Input.is_action_pressed("move_right"):
		current_frequency = minf(FREQUENCY_MAX, current_frequency + delta * CURSOR_SPEED)
	queue_redraw()

	if abs(current_frequency - target_frequency) < 0.1:
		time_on_frequency += delta
		if time_on_frequency >= REQUIRED_TIME_ON_FREQUENCY:
			_complete_minigame()
	else:
		time_on_frequency = 0.0

	frequency_label.text = "%.1f MHz" % current_frequency


func _draw() -> void:
	if not is_active:
		return

	var line_start := Vector2(size.x / 2 - LINE_WIDTH / 2, size.y / 2)
	var line_end := Vector2(size.x / 2 + LINE_WIDTH / 2, size.y / 2)

	# Draw the frequency line
	draw_line(line_start, line_end, Color.WHITE, 2.0)

	# Draw the cursor
	var cursor_x := line_start.x + (current_frequency - FREQUENCY_MIN) / (FREQUENCY_MAX - FREQUENCY_MIN) * LINE_WIDTH
	var cursor_pos := Vector2(cursor_x, size.y / 2)
	draw_line(cursor_pos - Vector2(0, 15), cursor_pos + Vector2(0, 15), Color.WHITE, 2.0)


func start_minigame() -> void:
	target_frequency = randf_range(FREQUENCY_MIN, FREQUENCY_MAX)
	current_frequency = (FREQUENCY_MIN + FREQUENCY_MAX) / 2
	time_on_frequency = 0.0
	is_active = true
	show()
	queue_redraw()
	_update_feedback()


func _complete_minigame() -> void:
	is_active = false
	hide()
	minigame_completed.emit()


func _update_feedback() -> void:
	var distance: float = abs(current_frequency - target_frequency)
	# TODO: Implement audio feedback based on distance to target frequency
	# Lower static/noise as player gets closer to target frequency
