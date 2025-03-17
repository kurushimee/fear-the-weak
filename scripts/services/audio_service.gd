extends Node

const BUS = "SFX"


func play(stream: AudioStream, position = null) -> void:
	var player = null
	if position:
		player = AudioStreamPlayer2D.new()
	else:
		player = AudioStreamPlayer.new()
	add_child(player)

	player.bus = BUS
	player.stream = stream
	if position:
		player.global_position = position
	player.play()

	await player.finished
	player.queue_free()
