class_name Radio
extends StaticBody2D

@export var player: CharacterBody2D

@onready var interactable: Interactable = $Interactable
@onready var minigame_ui: RadioMinigameUI = $RadioMinigameUI


func _ready() -> void:
	minigame_ui.minigame_completed.connect(_on_minigame_completed)


func _on_interacted() -> void:
	player.set_input_enabled(false)
	minigame_ui.start_minigame()


func _on_minigame_completed() -> void:
	player.set_input_enabled(true)
