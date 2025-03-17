extends StaticBody2D

signal passed_through

## The player will be teleported to this Node2D's position.
@export var destination: Node2D

@export var temp_sfx: PackedScene

@onready var open_sound: AudioStreamPlayer2D = $OpenSound
@onready var close_sound: AudioStreamPlayer2D = $CloseSound


func _on_interacted() -> void:
	open_sound.play()
	await ScreenFadeEffect.instance.fade_out()

	Player.instance.global_position = destination.global_position
	passed_through.emit()

	await ScreenFadeEffect.instance.fade_in()
	AudioService.play(close_sound.stream, global_position)
