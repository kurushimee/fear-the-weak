extends AudioStreamPlayer2D


func play_at_pos(pos: Vector2, sfx: AudioStream) -> void:
	global_position = pos
	stream = sfx
	play()
