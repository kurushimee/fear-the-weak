extends Node2D

@onready var cabin: Node2D = $Cabin


func _on_exited_cabin() -> void:
	remove_child(cabin)
	await get_tree().process_frame # Wait for interactables to be gone.
	Player.instance.update_interaction() # Fixes prompt stuck visible.
