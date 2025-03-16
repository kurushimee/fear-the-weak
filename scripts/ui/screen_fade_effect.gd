class_name ScreenFadeEffect
extends CanvasLayer

const MIN_VOLUME := -50.0

const FADE_IN_ANIM := &"fade_in"
const FADE_OUT_ANIM := &"fade_out"

static var instance: ScreenFadeEffect

@export var animation_player: AnimationPlayer
@export var timer: Timer

var timer_running := false


func _ready() -> void:
	instance = self
	fade_in()


func _process(_delta: float) -> void:
	if not timer_running: return

	var volume := 0.0
	match animation_player.current_animation:
		FADE_IN_ANIM:
			volume = MIN_VOLUME * (timer.time_left / timer.wait_time)
		FADE_OUT_ANIM:
			volume = MIN_VOLUME * ((timer.wait_time - timer.time_left) / timer.wait_time)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)


func start_timer() -> void:
	timer.wait_time = animation_player.get_animation(animation_player.current_animation).length
	timer.start()
	timer_running = true
	await timer.timeout
	timer_running = false


func play_animation(animation_name: StringName) -> void:
	animation_player.play(animation_name)
	start_timer()
	await animation_player.animation_finished


func fade_in() -> void:
	await play_animation(FADE_IN_ANIM)


func fade_out() -> void:
	await play_animation(FADE_OUT_ANIM)
