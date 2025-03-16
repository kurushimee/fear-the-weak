extends Node2D

signal entered_cabin

@export var background_music: AudioStreamPlayer
@export var blizzard: AudioStreamPlayer


func reset_audio() -> void:
	background_music.play()
	blizzard.play()


func _on_cabin_door_passed_through() -> void:
	entered_cabin.emit()
