extends Node2D

signal exited_cabin

@export var background_music: AudioStream
@export var ambience: AudioStreamPlayer
@export var locator: Locator


func reset_audio() -> void:
	AudioService.play_music(background_music)
	ambience.play()


## Called when the radio minigame is completed
func activate_locator() -> void:
	locator.activate()


## Plays the background music after a start delay.
func _on_start_delay_timeout() -> void:
	AudioService.play_music(background_music)


func _on_door_passed_through() -> void:
	exited_cabin.emit()
