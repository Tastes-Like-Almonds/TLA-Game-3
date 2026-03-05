## Manages layers of music tracks.
extends Node

enum TrackLayer {
	AMBIENT,
	MUSIC,
}

var tracks : Dictionary[TrackLayer, SongData]

func start_track(track:TrackLayer, song:SongData, _fade_time:float=1.0) -> void:
	if not song: return
	tracks[track] = song
	
	song.node_ref = AudioStreamPlayer.new()
	song.node_ref.stream = load(song.path)
	song.node_ref.bus = &"Music"
	song.node_ref.volume_linear = song.vol_linear

	# TODO Add fading + Stop track implementation

	add_child(song.node_ref)
	song.node_ref.play()

func stop_track(track:TrackLayer, fade_time:float=0.5) -> void:
	pass

func _ready() -> void:
	for track:int in TrackLayer.values():
		tracks[track] = null
