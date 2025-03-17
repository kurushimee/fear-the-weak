extends StaticBody2D

signal passed_through

## The player will be teleported to this Node2D's position.
@export var destination: Node2D

@export var open_sfx: AudioStream
@export var close_sfx: AudioStream


func _on_interacted() -> void:
	AudioService.play_sfx(open_sfx, global_position)
	await ScreenFadeEffect.instance.fade_out()

	Player.instance.global_position = destination.global_position
	passed_through.emit()

	await ScreenFadeEffect.instance.fade_in()
	AudioService.play_sfx(close_sfx, global_position)
