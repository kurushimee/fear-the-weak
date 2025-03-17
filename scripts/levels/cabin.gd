extends Node2D

signal exited_cabin

## AnimationPlayer child node of BackgroundMusic.
@export var background_music_ap: AnimationPlayer

@export var background_music: AudioStreamPlayer
@export var ambience: AudioStreamPlayer
@export var locator: Locator


func reset_audio() -> void:
	background_music.play()
	ambience.play()


## Plays the background music after a start delay.
func _on_start_delay_timeout() -> void:
	background_music_ap.play(&"fade_in")


func _on_door_passed_through() -> void:
	exited_cabin.emit()


## Called when the radio minigame is completed
func activate_locator() -> void:
	if locator:
		# Activate the next destination in the locator
		locator.activate()
