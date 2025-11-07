## Manages one-shot sound effects.
extends Node2D

# Parent nodes for sounds. Initialized at _ready()
var sound_2d_parent : Node2D
var sound_parent : Node

## Gets an audiostream from the given SoundData. Returns null if not a stream or invalid.
func get_stream_from_sound(sound : SoundData) -> AudioStream:
	
	var stream := load(sound.sound_string)
	
	if not stream or (stream is not AudioStream): return null
	return stream

## Plays a sound at the target position
func play_sound_2d(sound:SoundData, pos:Vector2, override_previous:bool = true) -> void:
	var stream := get_stream_from_sound(sound)
	
	if stream == null: 
		push_warning("Attempt to load invalid stream '" + sound.sound_string + "'")
		return
	
	# Check if sound already exists
	if override_previous:
		for child in sound_2d_parent.get_children():
			if child.get_meta("sound_path") == sound.sound_string: child.queue_free()
	
	var stream_player := AudioStreamPlayer2D.new()
	stream_player.bus = sound.bus
	stream_player.stream = stream
	stream_player.volume_linear = sound.volume_linear
	stream_player.pitch_scale = sound.pitch_scale
	stream_player.set_meta("sound_path", sound.sound_string)
	
	sound_2d_parent.add_child(stream_player)
	stream_player.global_position = pos
	stream_player.play()

## Plays a sound. If the sound is currenty playing, and override_previous is true, the previous
## sound will cancel.
func play_sound(sound:SoundData, override_previous:bool = true) -> void:
	var stream := get_stream_from_sound(sound)
	
	if stream == null: 
		push_warning("Attempt to load invalid stream '" + sound.sound_string + "'")
		return
	
	# Check if sound already exists
	if override_previous:
		for child in sound_parent.get_children():
			if child.get_meta("sound_path") == sound.sound_string: child.queue_free()
	
	var stream_player := AudioStreamPlayer.new()
	stream_player.bus = sound.bus
	stream_player.stream = stream
	stream_player.volume_linear = sound.volume_linear
	stream_player.pitch_scale = sound.pitch_scale
	stream_player.set_meta("sound_path", sound.sound_string)
	
	sound_parent.add_child(stream_player)
	stream_player.play()

func _ready() -> void:
	
	sound_2d_parent = Node2D.new()
	sound_parent = Node.new()
	
	add_child(sound_2d_parent)
	add_child(sound_parent)
