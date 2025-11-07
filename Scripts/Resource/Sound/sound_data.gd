## Contains data for a sound, such as the volume, pitch, etc.
class_name SoundData extends Resource
	
@export_file_path("*.mp3", "*.wav") var sound_string : String
@export var volume_linear : float = 0.5
@export var pitch_scale : float = 1.0
@export var bus : StringName = &"Master"

func _init(path : String="", vol_linear : float = 0.5, pitch : float = 1.0) -> void:
	sound_string = path
	volume_linear = vol_linear
	pitch_scale = pitch
