extends Node2D

## AnimationPlayer child node of BackgroundMusic.
@export var background_music_ap: AnimationPlayer
@export var screen_fade_effect: CanvasLayer


func _ready() -> void:
	screen_fade_effect.fade_in()


## Plays the background music after a start delay.
func _on_start_delay_timeout() -> void:
	background_music_ap.play(&"fade_in")
