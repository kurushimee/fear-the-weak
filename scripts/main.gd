extends Node2D

var cabin: Node2D
var forest: Node2D


func _ready() -> void:
	cabin = $Cabin
	forest = $Forest
	remove_child(forest)


func change_location(from: Node2D, to: Node2D) -> void:
	remove_child(from)
	add_child(to)
	to.reset_audio()

	await get_tree().process_frame # Wait for interactables to be gone.
	Player.instance.update_interaction() # Fixes prompt stuck visible.


func _on_exited_cabin() -> void:
	change_location(cabin, forest)


func _on_entered_cabin() -> void:
	change_location(forest, cabin)
