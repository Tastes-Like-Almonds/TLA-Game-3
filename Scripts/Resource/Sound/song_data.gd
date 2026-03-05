class_name SongData extends Resource

## Path to the audio file.
@export var path:StringName

## If set, the song will only change after a measure has completed.
@export var measure_length:float = 0.0

## Linear volume
@export var vol_linear:float = 0.6

## Reference to audio stream node; used internally in Music.gd.
var node_ref:Node

func _ready() -> void:
	assert(FileAccess.file_exists(path), "Song path '" + path + "' not found!")
