class_name Interactable
extends Node

signal interacted
signal prompt_changed

@export var interaction_prompt: String = "interact":
	set = set_prompt
@export var is_active: bool = true


func interact() -> void:
	if not is_active: return
	interacted.emit()


func set_prompt(prompt: String) -> void:
	interaction_prompt = prompt
	prompt_changed.emit()
