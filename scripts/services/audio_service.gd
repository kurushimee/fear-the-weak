extends Node

const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

var music_player: AudioStreamPlayer
var tween: Tween


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = MUSIC_BUS


## Plays a sound effect
func play_sfx(sfx: AudioStream, position = null) -> void:
	var player = null
	if position:
		player = AudioStreamPlayer2D.new()
	else:
		player = AudioStreamPlayer.new()
	add_child(player)

	player.bus = SFX_BUS
	player.stream = sfx
	if position:
		player.global_position = position
	player.play()

	await player.finished
	player.queue_free()


## Plays music with a smooth fade-in over 1 second
func play_music(track: AudioStream) -> void:
	if music_player.playing:
		await stop_music()

	music_player.stream = track
	music_player.volume_db = -80.0
	music_player.play()

	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(music_player, "volume_db", 0.0, 1.0)


## Stops the currently playing music with a fade-out
func stop_music(fade_time: float = 1.0) -> void:
	if tween:
		tween.kill()

	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(music_player, "volume_db", -80.0, fade_time)
	await tween.finished
	music_player.stop()
