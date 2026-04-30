## Manages layers of music tracks.
extends Node

enum TrackLayer {
	AMBIENT,
	MUSIC,
}

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

	# TODO Add fading + Stop track implementation

	print("NODE  CREATED")
	add_child(song.node_ref)
	song.node_ref.play(start_time)

func stop_track(track:TrackLayer, fade_time:float=0.5) -> void:
	if !tracks.has(track): return
	var song := tracks[track]
	
	if not song: return
	if fade_time <= 0.0:
		if is_instance_valid(song.node_ref):
			song.node_ref.queue_free()
	else:
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
				#song.node_ref.queue_free()
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

func _ready() -> void:
	for track:int in TrackLayer.values():
		tracks[track] = null
