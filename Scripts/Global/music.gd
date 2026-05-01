## Manages layers of music tracks.
extends Node

enum TrackLayer {
	AMBIENT,
	MUSIC,
}

var muffle_music : bool = false
var tracks : Dictionary[TrackLayer, SongData]

func start_track(track:TrackLayer, song:SongData, fade_time:float=0.0, keep_time:bool=false) -> void:
	if not song: return
	
	#Allow songs to continually play; doesn't work for some reason.
	#if song.path == tracks[track].path: return
	
	var start_time : float = 0.0
	if tracks[track]:
		if keep_time:
			start_time = tracks[track].node_ref.get_playback_position()
		stop_track(track, fade_time)
	
	tracks[track] = song
	
	song.node_ref = AudioStreamPlayer.new()
	song.node_ref.stream = load(song.path)
	song.node_ref.bus = &"Music"
	song.node_ref.volume_linear = song.vol_linear
	song.node_ref.process_mode = Node.PROCESS_MODE_ALWAYS

	if fade_time > 0.0:
		song.node_ref.volume_linear = 0
		var fade_tween := create_tween()
			
		# Fade to target volume
		fade_tween.tween_property(
			song.node_ref,
			"volume_linear",
			song.vol_linear,
			fade_time
		)
		
		fade_tween.play()

	print("NODE  CREATED")
	add_child(song.node_ref)
	start_time = clampf(start_time, 0.0, song.node_ref.stream.get_length())
	song.node_ref.play(start_time)

func stop_track(track:TrackLayer, fade_time:float=0.5) -> void:
	if !tracks.has(track): return
	var song := tracks[track]
	
	if not song: return
	if fade_time <= 0.0:
		if is_instance_valid(song.node_ref):
			song.node_ref.queue_free()
	else:
		if not song.node_ref: return
		var fade_tween := create_tween()
		# Fade to zero volume
		fade_tween.tween_property(
			song.node_ref,
			"volume_linear",
			0,
			fade_time
		)
		
		# Delete node reference upon fade completion
		fade_tween.tween_callback(func() -> void:
			if song.node_ref and song.node_ref.is_node_ready() and is_instance_valid(song.node_ref):
				print(song.path)
				print(song.node_ref)
				print(song.node_ref.get_parent())
				song.node_ref.queue_free()
		)
		
		fade_tween.play()

func set_track_volume(track:TrackLayer, volume:float, time:float=0.5) -> void:
	var fade_tween := create_tween()
	if !tracks.has(track): return
	var song := tracks[track]
	
	if not song: return
	# Fade to zero volume
	fade_tween.tween_property(
		song.node_ref,
		"volume_linear",
		volume,
		time
	)

func _process(delta: float) -> void:
	var bus_idx := AudioServer.get_bus_index("Music")
	var effect : AudioEffectLowPassFilter = AudioServer.get_bus_effect(bus_idx, 0)
	if muffle_music:
		effect.resonance = lerpf(effect.resonance, 0.65, 1-pow(0.005,delta))
		effect.cutoff_hz = lerpf(effect.cutoff_hz, 1000, 1-pow(0.005,delta))
	else:
		effect.resonance = lerpf(effect.resonance, 0.5,   1-pow(0.02,delta))
		effect.cutoff_hz = lerpf(effect.cutoff_hz, 20500, 1-pow(0.02,delta))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for track:int in TrackLayer.values():
		tracks[track] = null
