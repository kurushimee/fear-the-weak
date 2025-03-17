class_name Radio
extends StaticBody2D

@export var cabin: Node2D

@onready var interactable: Interactable = $Interactable
@onready var minigame_ui: RadioMinigameUI = $CanvasLayer/RadioMinigameUI


func _ready() -> void:
	minigame_ui.minigame_completed.connect(_on_minigame_completed)


func _on_interacted() -> void:
	Player.instance.set_input_enabled(false)
	minigame_ui.start_minigame()


func _on_minigame_completed() -> void:
	interactable.is_active = false
	Player.instance.set_input_enabled(true)
	
	# Activate the locator through the cabin
	if cabin and cabin.has_method(&"activate_locator"):
		cabin.activate_locator()
