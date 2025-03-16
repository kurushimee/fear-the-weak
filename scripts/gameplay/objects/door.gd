extends StaticBody2D

signal passed_through

## The player will be teleported to this Node2D's position.
@export var destination: Node2D


func _on_interacted() -> void:
	await ScreenFadeEffect.instance.fade_out()
	Player.instance.global_position = destination.global_position
	passed_through.emit()
	ScreenFadeEffect.instance.fade_in()
