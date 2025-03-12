extends Area2D

@onready var interactable: Interactable = $Interactable


func _on_interacted() -> void:
	print("Collected a key")
	interactable.is_active = false
