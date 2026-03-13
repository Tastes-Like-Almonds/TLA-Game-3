## Manages layers of music tracks.
extends Node

enum TrackLayer {
	AMBIENT,
	MUSIC,
}

var tracks : Dictionary[TrackLayer, SongData]

func start_track(track:TrackLayer, song:SongData, fade_time:float=0.0) -> void:
	if not song: return
	
	if song == tracks[track]: return
	
	if tracks[track]:
		stop_track(track, fade_time)
	
	tracks[track] = song
	
	song.node_ref = AudioStreamPlayer.new()
	song.node_ref.stream = load(song.path)
	song.node_ref.bus = &"Music"
	song.node_ref.volume_linear = song.vol_linear

	# TODO Add fading + Stop track implementation

	add_child(song.node_ref)
	song.node_ref.play()

func stop_track(track:TrackLayer, fade_time:float=0.5) -> void:
	if !tracks.has(track): return
	var song := tracks[track]
	
	if fade_time <= 0.0:
		song.node_ref.queue_free()
		tracks[track] = null
	else:
		# TODO
		var fade_tween := Tween.new()

func _ready() -> void:
	for track:int in TrackLayer.values():
		tracks[track] = null
