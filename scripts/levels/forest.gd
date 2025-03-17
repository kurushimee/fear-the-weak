extends Node2D

signal entered_cabin

@export var background_music: AudioStream
@export var blizzard: AudioStreamPlayer
@export var locator: Locator


func reset_audio() -> void:
	AudioService.play_music(background_music)
	blizzard.play()


func _on_cabin_door_passed_through() -> void:
	entered_cabin.emit()
